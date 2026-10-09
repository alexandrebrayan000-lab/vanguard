-- ============================================================
--  VANGUARD BARBEARIA — Setup completo do banco de dados
--  Cole este script no Supabase → SQL Editor → Run
-- ============================================================

-- ============================================================
-- 1. TABELAS
-- ============================================================

-- Usuários (clientes e admins)
CREATE TABLE IF NOT EXISTS public.usuarios (
  id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome      TEXT        NOT NULL,
  cpf       TEXT        NOT NULL,
  whatsapp  TEXT        NOT NULL,
  email     TEXT        DEFAULT '',
  senha     TEXT        NOT NULL,
  foto      TEXT        DEFAULT '',
  admin     BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Serviços
CREATE TABLE IF NOT EXISTS public.servicos (
  id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome      TEXT        NOT NULL,
  preco     NUMERIC     NOT NULL,
  duracao   TEXT        DEFAULT '',
  foto      TEXT        DEFAULT '',
  imageFit  TEXT        DEFAULT 'cover',
  zoom      INTEGER     DEFAULT 100,
  "posX"    INTEGER     DEFAULT 0,
  "posY"    INTEGER     DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Barbeiros
CREATE TABLE IF NOT EXISTS public.barbeiros (
  id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome           TEXT    NOT NULL,
  especialidade  TEXT    DEFAULT '',
  foto           TEXT    DEFAULT '',
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Produtos
CREATE TABLE IF NOT EXISTS public.produtos (
  id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome      TEXT        NOT NULL,
  preco     NUMERIC     NOT NULL,
  foto      TEXT        DEFAULT '',
  imageFit  TEXT        DEFAULT 'cover',
  zoom      INTEGER     DEFAULT 100,
  "posX"    INTEGER     DEFAULT 0,
  "posY"    INTEGER     DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Agendamentos
CREATE TABLE IF NOT EXISTS public.agendamentos (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cliente     TEXT    NOT NULL,
  whatsapp    TEXT    NOT NULL,
  data        DATE    NOT NULL,
  hora        TEXT    NOT NULL,
  "servicoId" BIGINT  REFERENCES public.servicos(id) ON DELETE SET NULL,
  "barbeiroId" BIGINT REFERENCES public.barbeiros(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Feedbacks
CREATE TABLE IF NOT EXISTS public.feedbacks (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cliente     TEXT    NOT NULL,
  "barbeiroId" BIGINT REFERENCES public.barbeiros(id) ON DELETE SET NULL,
  comentario  TEXT    DEFAULT '',
  nota        INTEGER DEFAULT NULL,
  data        TEXT    DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Galeria
CREATE TABLE IF NOT EXISTS public.galeria (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  foto        TEXT    NOT NULL,
  descricao   TEXT    DEFAULT '',
  imageFit    TEXT    DEFAULT 'contain',
  zoom        INTEGER DEFAULT 100,
  "posX"      INTEGER DEFAULT 0,
  "posY"      INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);


-- ============================================================
-- 2. ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE public.usuarios    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.servicos    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barbeiros   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agendamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedbacks   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.galeria     ENABLE ROW LEVEL SECURITY;

-- usuarios
CREATE POLICY "usuarios_select" ON public.usuarios FOR SELECT USING (true);
CREATE POLICY "usuarios_insert" ON public.usuarios FOR INSERT WITH CHECK (true);
CREATE POLICY "usuarios_update" ON public.usuarios FOR UPDATE USING (true) WITH CHECK (true);

-- servicos
CREATE POLICY "servicos_select" ON public.servicos FOR SELECT USING (true);
CREATE POLICY "servicos_insert" ON public.servicos FOR INSERT WITH CHECK (true);
CREATE POLICY "servicos_update" ON public.servicos FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "servicos_delete" ON public.servicos FOR DELETE USING (true);

-- barbeiros
CREATE POLICY "barbeiros_select" ON public.barbeiros FOR SELECT USING (true);
CREATE POLICY "barbeiros_insert" ON public.barbeiros FOR INSERT WITH CHECK (true);
CREATE POLICY "barbeiros_update" ON public.barbeiros FOR UPDATE USING (true) WITH CHECK (true);

-- produtos
CREATE POLICY "produtos_select" ON public.produtos FOR SELECT USING (true);
CREATE POLICY "produtos_insert" ON public.produtos FOR INSERT WITH CHECK (true);
CREATE POLICY "produtos_update" ON public.produtos FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "produtos_delete" ON public.produtos FOR DELETE USING (true);

-- agendamentos
CREATE POLICY "agendamentos_select" ON public.agendamentos FOR SELECT USING (true);
CREATE POLICY "agendamentos_insert" ON public.agendamentos FOR INSERT WITH CHECK (true);
CREATE POLICY "agendamentos_update" ON public.agendamentos FOR UPDATE USING (true) WITH CHECK (true);

-- feedbacks
CREATE POLICY "feedbacks_select" ON public.feedbacks FOR SELECT USING (true);
CREATE POLICY "feedbacks_insert" ON public.feedbacks FOR INSERT WITH CHECK (true);

-- galeria
CREATE POLICY "galeria_select" ON public.galeria FOR SELECT USING (true);
CREATE POLICY "galeria_insert" ON public.galeria FOR INSERT WITH CHECK (true);
CREATE POLICY "galeria_update" ON public.galeria FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "galeria_delete" ON public.galeria FOR DELETE USING (true);


-- ============================================================
-- 3. USUÁRIO ADMIN INICIAL
--    ⚠️ Troque a senha após o primeiro login!
-- ============================================================
INSERT INTO public.usuarios (nome, cpf, whatsapp, email, senha, foto, admin)
VALUES ('Admin', '000.000.000-00', '00000000000', 'admin@vanguard.com', 'admin123', '', TRUE)
ON CONFLICT DO NOTHING;


-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
