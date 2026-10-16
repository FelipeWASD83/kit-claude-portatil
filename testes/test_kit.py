"""Testes do kit-claude-portatil.

Gera o pacote de verdade, instala numa "casa" de mentira (KIT_HOME) e numa pasta
temporaria com o Windows PowerShell 5.1 (o mesmo que a pessoa vai usar) e confere o que
ficou. Nada toca no ~/.claude real, no `claude mcp` nem na internet.

Rodar, na raiz do projeto:
    python -m unittest discover -s testes -v
"""
import functools
import http.server
import json
import os
import re
import shutil
import subprocess
import tempfile
import threading
import unittest
import zipfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
PS = shutil.which("powershell.exe") or "powershell.exe"
SKILLS_ESPERADAS = {
    "primeira-configuracao", "inicializar-pasta", "direcao-visual", "revisar-visual", "checklist-web",
    "entregar-site", "revisar-codigo", "pesquisa-tecnica", "gml", "video-motion", "depurar",
    "diagnosticar-pc", "backup-local",
}


def ps(*args, env=None, cwd=None, timeout=300):
    e = dict(os.environ)
    e.update(env or {})
    return subprocess.run([PS, "-NoProfile", "-ExecutionPolicy", "Bypass", *args], capture_output=True,
                          text=True, encoding="utf-8", errors="replace", env=e, cwd=cwd, timeout=timeout)


def ps_script(script, *args, env=None, cwd=None):
    return ps("-File", str(script), *args, env=env, cwd=cwd)


class Base(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = Path(tempfile.mkdtemp(prefix="kit-teste-"))
        cls.dist = cls.tmp / "dist"
        r = ps_script(RAIZ / "ferramentas" / "montar-pacote.ps1", "-Saida", str(cls.dist))
        assert r.returncode == 0, r.stdout + r.stderr
        cls.zip = cls.dist / "kit.zip"

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.tmp, ignore_errors=True)

    def instalar(self, casa, pasta, *extra, env=None, zip_=None):
        e = {"KIT_HOME": str(casa)}
        e.update(env or {})
        return ps_script(RAIZ / "instalar.ps1", "-ArquivoLocal", str(zip_ or self.zip), "-Destino", str(pasta),
                         "-Sim", "-SemVideo", "-SemMcp", *extra, env=e)

    def nova(self, nome):
        casa = self.tmp / nome / "home"
        pasta = self.tmp / nome / "Trabalho"
        casa.mkdir(parents=True)
        return casa, pasta


class TestPacote(Base):
    def test_zip_com_barras_e_sem_lixo(self):
        with zipfile.ZipFile(self.zip) as z:
            nomes = z.namelist()
        self.assertIn("versao.json", nomes)
        self.assertIn("conteudo/pasta/CLAUDE.md", nomes)
        self.assertIn("conteudo/global/CLAUDE.md", nomes)
        self.assertFalse([n for n in nomes if "\\" in n], "entrada do zip com barra invertida")
        self.assertFalse([n for n in nomes if "__pycache__" in n or n.endswith(".pyc")])
        self.assertFalse([n for n in nomes if n.startswith("ferramentas/") or n.startswith("testes/")])

    def test_sha256_bate(self):
        import hashlib
        esperado = re.search(r"[0-9a-f]{64}", (self.dist / "kit.zip.sha256").read_text()).group(0)
        self.assertEqual(esperado, hashlib.sha256(self.zip.read_bytes()).hexdigest())

    def test_privacidade_do_zip(self):
        r = subprocess.run(["python", "-I", str(RAIZ / "ferramentas" / "verificar-privacidade.py"), "--zip", str(self.zip)],
                           capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(r.returncode, 0, r.stdout)

    def test_scripts_do_instalador_sao_ascii_sem_bom(self):
        arquivos = [RAIZ / "instalar.ps1", *(RAIZ / "conteudo" / "pasta" / "_organizacao").glob("*.ps1"),
                    *(RAIZ / "ferramentas").glob("*.ps1")]
        for a in arquivos:
            b = a.read_bytes()
            self.assertFalse(b.startswith(b"\xef\xbb\xbf"), f"{a.name} tem BOM")
            self.assertTrue(all(c < 128 for c in b), f"{a.name} tem caractere nao ASCII")

    def test_ps1_sem_erro_de_sintaxe_no_5_1(self):
        arquivos = [RAIZ / "instalar.ps1", *(RAIZ / "conteudo").rglob("*.ps1"), *(RAIZ / "ferramentas").glob("*.ps1")]
        comando = ("$ok=$true; foreach($f in $args){$e=$null;$t=$null;"
                   "[void][System.Management.Automation.Language.Parser]::ParseFile($f,[ref]$t,[ref]$e);"
                   "if($e){$ok=$false;$e|ForEach-Object{$f+': '+$_.Message+' @'+$_.Extent.StartLineNumber}}};"
                   "if($ok){'OK'}")
        r = ps("-Command", comando, *[str(a) for a in arquivos])
        self.assertEqual(r.stdout.strip(), "OK", r.stdout + r.stderr)


class TestSkills(unittest.TestCase):
    def frontmatter(self, p):
        t = p.read_text(encoding="utf-8")
        m = re.match(r"---\r?\n(.*?)\r?\n---", t, re.S)
        self.assertIsNotNone(m, f"{p} sem frontmatter")
        return dict(re.findall(r"^([A-Za-z-]+):\s*(.*)$", m.group(1), re.M))

    def test_skills_da_pasta(self):
        base = RAIZ / "conteudo" / "pasta" / ".claude" / "skills"
        pastas = {p.name for p in base.iterdir() if p.is_dir()}
        self.assertEqual(pastas, SKILLS_ESPERADAS)
        for nome in pastas:
            fm = self.frontmatter(base / nome / "SKILL.md")
            self.assertEqual(fm.get("name"), nome)
            self.assertTrue(fm.get("description", "").strip(), f"{nome} sem description")

    def test_skills_globais(self):
        base = RAIZ / "conteudo" / "global" / "skills"
        self.assertEqual({p.name for p in base.iterdir() if p.is_dir()}, {"ver-video", "context7-mcp"})
        for nome in ("ver-video", "context7-mcp"):
            self.assertEqual(self.frontmatter(base / nome / "SKILL.md").get("name"), nome)

    def test_skills_manuais(self):
        base = RAIZ / "conteudo" / "pasta" / ".claude" / "skills"
        manuais = {n for n in SKILLS_ESPERADAS if self.frontmatter(base / n / "SKILL.md").get("disable-model-invocation") == "true"}
        self.assertEqual(manuais, {"primeira-configuracao", "inicializar-pasta", "entregar-site", "revisar-visual"})

    def test_marcadores_do_github_pareados(self):
        skill = (RAIZ / "conteudo/pasta/.claude/skills/primeira-configuracao/SKILL.md").read_text(encoding="utf-8")
        self.assertEqual(skill.count("<!-- github-recomendacao:inicio -->"), 1)
        self.assertEqual(skill.count("<!-- github-recomendacao:fim -->"), 1)
        # tirar o bloco (o que o Claude faz depois de recomendar) deixa uma skill inteira e sem marca
        sem = re.sub(r"<!-- github-recomendacao:inicio -->.*?<!-- github-recomendacao:fim -->\n\n", "", skill, flags=re.S)
        self.assertNotIn("github-recomendacao", sem)
        self.assertNotIn("recomendar com força", sem)
        self.assertIn("## 6. Fechar", sem)
        claude = (RAIZ / "conteudo/pasta/CLAUDE.md").read_text(encoding="utf-8")
        self.assertEqual(claude.count("<!-- github:inicio -->"), 1)
        self.assertEqual(claude.count("<!-- github:fim -->"), 1)

    def test_claude_md_cita_as_treze_skills(self):
        claude = (RAIZ / "conteudo/pasta/CLAUDE.md").read_text(encoding="utf-8")
        for nome in SKILLS_ESPERADAS:
            self.assertIn(f"`{nome}`", claude, f"{nome} nao aparece no CLAUDE.md")


class TestInstalacao(Base):
    def test_instalacao_nova(self):
        casa, pasta = self.nova("nova")
        r = self.instalar(casa, pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("SHA-256 conferido", r.stdout)
        self.assertTrue((pasta / "CLAUDE.md").is_file())
        self.assertTrue((pasta / "_REVISAR").is_dir())
        skills = {p.name for p in (pasta / ".claude" / "skills").iterdir() if p.is_dir()}
        self.assertEqual(skills, SKILLS_ESPERADAS)
        self.assertTrue((pasta / ".claude" / "referencias-visuais" / "prints").is_dir())
        self.assertTrue((pasta / "_organizacao" / "backup-local.ps1").is_file())
        self.assertFalse((pasta / "_organizacao" / "backup-destino.txt").exists())
        c = casa / ".claude"
        self.assertTrue((c / "skills" / "ver-video" / "ver_video.py").is_file())
        self.assertTrue((c / "skills" / "context7-mcp" / "SKILL.md").is_file())
        self.assertTrue((c / "rules" / "context7.md").is_file())
        self.assertIn("_(preencher)_", (c / "CLAUDE.md").read_text(encoding="utf-8"))
        self.assertTrue((c / "CLAUDE.kit-modelo.md").is_file())
        perm = json.loads((c / "settings.json").read_text(encoding="utf-8"))["permissions"]
        self.assertIn("Read(./**/.env)", perm["deny"])
        self.assertIn("Bash(git push*)", perm["ask"])
        marca = json.loads((c / "kit-instalado.json").read_text(encoding="utf-8"))
        self.assertEqual(marca["versao"], json.loads((RAIZ / "versao.json").read_text())["versao"])
        self.assertEqual(Path(marca["pasta"]), pasta)
        self.assertFalse(marca["configurado"])
        self.assertIn("/primeira-configuracao", r.stdout)

    def test_atualizacao_preserva_o_que_e_dela(self):
        casa, pasta = self.nova("atualiza")
        self.assertEqual(self.instalar(casa, pasta).returncode, 0)
        (pasta / "CLAUDE.md").write_text("# meu texto\n", encoding="utf-8")
        (pasta / "LEIA-PRIMEIRO.md").unlink()
        (pasta / ".claude" / "settings.json").write_text('{"permissions":{"allow":["x"]}}', encoding="utf-8")
        (pasta / "meu-projeto").mkdir()
        (pasta / "meu-projeto" / "a.txt").write_text("dado", encoding="utf-8")
        skill = pasta / ".claude" / "skills" / "depurar" / "SKILL.md"
        original = skill.read_text(encoding="utf-8")
        skill.write_text("estragada", encoding="utf-8")
        r = self.instalar(casa, pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual((pasta / "CLAUDE.md").read_text(encoding="utf-8"), "# meu texto\n")
        self.assertFalse((pasta / "LEIA-PRIMEIRO.md").exists(), "arquivo apagado por ela voltou")
        self.assertEqual((pasta / ".claude" / "settings.json").read_text(encoding="utf-8"), '{"permissions":{"allow":["x"]}}')
        self.assertEqual((pasta / "meu-projeto" / "a.txt").read_text(encoding="utf-8"), "dado")
        self.assertEqual(skill.read_text(encoding="utf-8"), original, "skill do kit nao foi restaurada")
        backups = list((casa / ".claude" / "kit-backups").rglob("SKILL.md"))
        self.assertTrue(any(b.read_text(encoding="utf-8") == "estragada" for b in backups), "a versao trocada nao foi guardada")

    def test_atualizacao_acha_a_pasta_sozinha(self):
        casa, pasta = self.nova("acha")
        self.assertEqual(self.instalar(casa, pasta).returncode, 0)
        r = ps_script(RAIZ / "instalar.ps1", "-ArquivoLocal", str(self.zip), "-Sim", "-SemVideo", "-SemMcp",
                      env={"KIT_HOME": str(casa)})
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("instalacao anterior encontrada", r.stdout)

    def test_primeira_configuracao_feita_nao_volta(self):
        casa, pasta = self.nova("feita")
        self.assertEqual(self.instalar(casa, pasta).returncode, 0)
        marca = casa / ".claude" / "kit-instalado.json"
        d = json.loads(marca.read_text(encoding="utf-8"))
        d["configurado"] = True
        marca.write_text(json.dumps(d), encoding="utf-8")
        skill = pasta / ".claude" / "skills" / "primeira-configuracao" / "SKILL.md"
        skill.write_text("sem o passo do github", encoding="utf-8")
        r = self.instalar(casa, pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(skill.read_text(encoding="utf-8"), "sem o passo do github")
        self.assertTrue(json.loads(marca.read_text(encoding="utf-8"))["configurado"])
        self.assertNotIn("Proximo passo", r.stdout)

    def test_settings_existente_e_somado(self):
        casa, pasta = self.nova("settings")
        c = casa / ".claude"
        c.mkdir()
        (c / "settings.json").write_text(json.dumps({
            "theme": "dark",
            "hooks": {"Stop": [{"hooks": [{"type": "command", "command": "echo oi"}]}]},
            "permissions": {"deny": ["Read(./**/.env)"], "allow": ["Bash(ls*)"]},
        }), encoding="utf-8")
        r = self.instalar(casa, pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        cfg = json.loads((c / "settings.json").read_text(encoding="utf-8"))
        self.assertEqual(cfg["theme"], "dark")
        self.assertEqual(cfg["hooks"]["Stop"][0]["hooks"][0]["command"], "echo oi")
        self.assertEqual(cfg["permissions"]["deny"].count("Read(./**/.env)"), 1)
        self.assertIn("Read(./**/.env.*)", cfg["permissions"]["deny"])
        self.assertIn("Bash(ls*)", cfg["permissions"]["allow"])
        self.assertIn("Bash(git push*)", cfg["permissions"]["ask"])
        self.assertTrue(list((c / "kit-backups").rglob("settings.json")), "sem backup do settings.json antigo")

    def test_settings_invalido_nao_e_tocado(self):
        casa, pasta = self.nova("settings-ruim")
        c = casa / ".claude"
        c.mkdir()
        (c / "settings.json").write_text("{ isto nao e json", encoding="utf-8")
        r = self.instalar(casa, pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual((c / "settings.json").read_text(encoding="utf-8"), "{ isto nao e json")
        self.assertTrue((c / "settings.kit.json").is_file())

    def test_claude_md_pessoal_existente_nao_e_sobrescrito(self):
        casa, pasta = self.nova("claude-md")
        c = casa / ".claude"
        c.mkdir()
        (c / "CLAUDE.md").write_text("# Meu jeito\nresponda curto\n", encoding="utf-8")
        r = self.instalar(casa, pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual((c / "CLAUDE.md").read_text(encoding="utf-8"), "# Meu jeito\nresponda curto\n")
        self.assertIn("_(preencher)_", (c / "CLAUDE.kit-modelo.md").read_text(encoding="utf-8"))

    def test_destino_com_espaco_e_acento(self):
        casa, _ = self.nova("acento")
        pasta = self.tmp / "acento" / "Meus Projetos çã"
        r = self.instalar(casa, pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertTrue((pasta / "CLAUDE.md").is_file())

    def test_pacote_adulterado_nao_instala(self):
        casa, pasta = self.nova("adulterado")
        ruim = self.tmp / "adulterado" / "ruim"
        ruim.mkdir()
        shutil.copy(self.zip, ruim / "kit.zip")
        (ruim / "kit.zip.sha256").write_text("0" * 64 + "  kit.zip\n", encoding="utf-8")
        r = self.instalar(casa, pasta, zip_=ruim / "kit.zip")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("SHA-256 do kit nao confere", r.stdout + r.stderr)
        self.assertFalse((pasta / "CLAUDE.md").exists())
        self.assertFalse((casa / ".claude" / "kit-instalado.json").exists())


class _Quieto(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a):
        pass


class TestDownload(Base):
    def test_baixa_e_confere_pelo_http(self):
        handler = functools.partial(_Quieto, directory=str(self.dist))
        srv = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
        threading.Thread(target=srv.serve_forever, daemon=True).start()
        try:
            casa, pasta = self.nova("http")
            r = ps_script(RAIZ / "instalar.ps1", "-BaseUrl", f"http://127.0.0.1:{srv.server_address[1]}/",
                          "-Destino", str(pasta), "-Sim", "-SemVideo", "-SemMcp", env={"KIT_HOME": str(casa)})
            self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
            self.assertIn("baixando http://127.0.0.1", r.stdout)
            self.assertIn("SHA-256 conferido", r.stdout)
            self.assertTrue((pasta / "CLAUDE.md").is_file())
        finally:
            srv.shutdown()

    def test_url_fora_do_ar_da_erro_claro(self):
        casa, pasta = self.nova("http-fora")
        r = ps_script(RAIZ / "instalar.ps1", "-BaseUrl", "http://127.0.0.1:9/", "-Destino", str(pasta), "-Sim",
                      "-SemVideo", "-SemMcp", env={"KIT_HOME": str(casa)})
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("Nao consegui baixar o kit", r.stdout + r.stderr)
        self.assertFalse((pasta / "CLAUDE.md").exists())


class TestScriptsDaPasta(Base):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.casa = cls.tmp / "scripts" / "home"
        cls.pasta = cls.tmp / "scripts" / "Trabalho"
        cls.casa.mkdir(parents=True)
        r = ps_script(RAIZ / "instalar.ps1", "-ArquivoLocal", str(cls.zip), "-Destino", str(cls.pasta), "-Sim",
                      "-SemVideo", "-SemMcp", env={"KIT_HOME": str(cls.casa)})
        assert r.returncode == 0, r.stdout + r.stderr

    def org(self, nome):
        return self.pasta / "_organizacao" / nome

    def test_checar_pasta_acusa_a_configuracao_pendente(self):
        r = ps_script(self.org("checar-pasta.ps1"), cwd=self.pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertIn("_(preencher)_", r.stdout)
        self.assertIn("backup-destino.txt nao existe", r.stdout)
        self.assertNotIn("Codex", r.stdout)

    def test_git_setup_cria_git_local_e_nao_cobra_github(self):
        proj = self.pasta / "meu-site"
        proj.mkdir(exist_ok=True)
        (proj / "index.html").write_text("<h1>oi</h1>", encoding="utf-8")
        r = ps_script(self.org("git-setup.ps1"), cwd=self.pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertTrue((proj / ".git").exists())
        self.assertIn("so local", r.stdout)
        self.assertNotIn("gh repo create", r.stdout)
        log = subprocess.run(["git", "-C", str(proj), "log", "--oneline"], capture_output=True, text=True)
        self.assertIn("primeiro commit", log.stdout)
        self.assertTrue((proj / ".gitignore").is_file())
        # rodar de novo nao mexe em nada
        r2 = ps_script(self.org("git-setup.ps1"), cwd=self.pasta)
        self.assertIn("0 com git novo", r2.stdout)

    def test_backup_sem_config_sai_3(self):
        cfg = self.org("backup-destino.txt")
        if cfg.exists():
            cfg.unlink()
        r = ps_script(self.org("backup-local.ps1"), cwd=self.pasta)
        self.assertEqual(r.returncode, 3, r.stdout + r.stderr)

    def test_backup_espelha_simula_e_recusa_destino_dentro(self):
        cfg = self.org("backup-destino.txt")
        destino = self.tmp / "scripts" / "backup"
        cfg.write_text(f"caminho={destino}\n", encoding="utf-8")
        sim = ps_script(self.org("backup-local.ps1"), "-Simular", cwd=self.pasta)
        self.assertEqual(sim.returncode, 0, sim.stdout + sim.stderr)
        self.assertFalse((destino / self.pasta.name / "CLAUDE.md").exists(), "simulacao copiou")
        proj = self.pasta / "projeto-com-git"
        proj.mkdir(exist_ok=True)
        (proj / "a.txt").write_text("dado", encoding="utf-8")
        subprocess.run(["git", "init", "-q", str(proj)], check=True)
        r = ps_script(self.org("backup-local.ps1"), cwd=self.pasta)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertTrue((destino / self.pasta.name / "CLAUDE.md").is_file())
        self.assertTrue((destino / "LEIA-PRIMEIRO.md").is_file())
        self.assertTrue((destino / self.pasta.name / "projeto-com-git" / ".git").exists(), "o .git tem que ir junto")
        # destino dentro da origem: recusa
        cfg.write_text(f"caminho={self.pasta / 'dentro'}\n", encoding="utf-8")
        d = ps_script(self.org("backup-local.ps1"), cwd=self.pasta)
        self.assertEqual(d.returncode, 1, d.stdout + d.stderr)
        self.assertIn("DENTRO", d.stdout)
        # drive que nao existe: 2, sem erro
        cfg.write_text("caminho=Q:\\\\nao-existe\\\\backup\n".replace("\\\\", "\\"), encoding="utf-8")
        z = ps_script(self.org("backup-local.ps1"), cwd=self.pasta)
        self.assertEqual(z.returncode, 2, z.stdout + z.stderr)
        cfg.unlink()

    def test_backup_trava_de_origem_vazia(self):
        vazia = self.tmp / "scripts" / "vazia"
        (vazia / "_organizacao").mkdir(parents=True)
        shutil.copy(self.org("backup-local.ps1"), vazia / "_organizacao" / "backup-local.ps1")
        (vazia / "_organizacao" / "backup-destino.txt").write_text(f"caminho={self.tmp / 'scripts' / 'bkp2'}\n", encoding="utf-8")
        r = ps_script(vazia / "_organizacao" / "backup-local.ps1", cwd=vazia)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("PULADO por seguranca", r.stdout)

    def test_salvar_config_copia_so_a_lista_fechada(self):
        h = self.tmp / "scripts" / "casa-salvar"
        (h / ".claude" / "rules").mkdir(parents=True)
        (h / ".claude" / "skills" / "ver-video" / "venv").mkdir(parents=True)
        (h / ".claude" / "CLAUDE.md").write_text("regras dela", encoding="utf-8")
        (h / ".claude" / "rules" / "a.md").write_text("regra", encoding="utf-8")
        (h / ".claude" / ".credentials.json").write_text("segredo", encoding="utf-8")
        (h / ".claude" / "skills" / "ver-video" / "venv" / "x.dll").write_text("grande", encoding="utf-8")
        (h / ".claude" / "skills" / "ver-video" / "SKILL.md").write_text("skill", encoding="utf-8")
        env = {"USERPROFILE": str(h), "HOME": str(h)}
        r = subprocess.run(["python", "-I", str(self.org("salvar-config.py"))], capture_output=True, text=True,
                           encoding="utf-8", env={**os.environ, **env})
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        destino = self.pasta / "_organizacao" / "config-agentes" / "claude"
        self.assertEqual((destino / "CLAUDE.md").read_text(encoding="utf-8"), "regras dela")
        self.assertTrue((destino / "rules" / "a.md").is_file())
        self.assertTrue((destino / "skills" / "ver-video" / "SKILL.md").is_file())
        self.assertFalse(list(destino.rglob(".credentials.json")))
        self.assertFalse(list(destino.rglob("x.dll")))
        shutil.rmtree(self.pasta / "_organizacao" / "config-agentes")


if __name__ == "__main__":
    unittest.main()
