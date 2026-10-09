document.addEventListener('DOMContentLoaded', () => {
  const cadastroForm = document.getElementById('formCadastro');
  const loginForm    = document.getElementById('formLogin');

  // -------------------------------------------------------------------------
  // Helper: normalise WhatsApp number (strip spaces, dashes, country code, etc.)
  // -------------------------------------------------------------------------
  function normalizarWhats(w) {
    return (w || '').replace(/[\s\-().+]/g, '').replace(/^55/, '');
  }

  // -------------------------------------------------------------------------
  // Helper: hash a plain-text password with SHA-256 via the Web Crypto API
  // -------------------------------------------------------------------------
  async function hashSenha(texto) {
    const encoder   = new TextEncoder();
    const data      = encoder.encode(texto);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    return Array.from(new Uint8Array(hashBuffer))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }

  // =========================================================================
  // CADASTRO
  // =========================================================================
  if (cadastroForm) {
    cadastroForm.addEventListener('submit', async (event) => {
      event.preventDefault();

      const btnSubmit = cadastroForm.querySelector('button[type="submit"]');
      btnSubmit.disabled    = true;
      btnSubmit.textContent = 'Salvando...';

      try {
        // Collect form values
        const nome     = document.getElementById('nome').value.trim();
        const cpf      = document.getElementById('cpf').value.trim();
        const whatsapp = normalizarWhats(document.getElementById('whatsapp').value.trim());
        const email    = document.getElementById('email')?.value?.trim() || '';
        const senhaRaw = document.getElementById('cadSenha')
          ? document.getElementById('cadSenha').value
          : document.getElementById('senha').value;

        // Hash the password before storing
        const senhaHash = await hashSenha(senhaRaw);

        // Build the synthetic email used for Supabase Auth
        const authEmail = `${whatsapp}@vanguard.app`;

        // -- Check for duplicate WhatsApp in usuarios table --
        const { data: existing, error: checkError } = await window._supabase
          .from('usuarios')
          .select('whatsapp')
          .eq('whatsapp', whatsapp);

        if (checkError) throw new Error(checkError.message);

        if (existing && existing.length > 0) {
          alert('Esse WhatsApp já está cadastrado.');
          btnSubmit.disabled    = false;
          btnSubmit.textContent = 'Cadastrar';
          return;
        }

        // -- Create Supabase Auth user --
        const { data: authData, error: signUpError } = await window._supabase.auth.signUp({
          email:    authEmail,
          password: senhaRaw,   // Supabase Auth handles its own hashing
        });

        if (signUpError) throw new Error(signUpError.message);

        // -- Insert user profile into the usuarios table --
        const { error: insertError } = await window._supabase
          .from('usuarios')
          .insert([{
            nome,
            cpf,
            whatsapp,
            email,
            foto:  '',
            admin: false,
            senha: senhaHash,   // SHA-256 hashed copy stored for app-level checks
            user_id: authData?.user?.id || null
          }]);

        if (insertError) throw new Error(insertError.message);

        // Save credentials in sessionStorage so the login form can be pre-filled
        sessionStorage.setItem('prefillWhats', whatsapp);
        sessionStorage.setItem('prefillSenha', senhaRaw);

        // Redirect to login
        window.location.href = 'login.html';

      } catch (e) {
        console.error('[auth.js] Erro ao cadastrar:', e);
        alert('Erro ao cadastrar: ' + e.message);
        btnSubmit.disabled    = false;
        btnSubmit.textContent = 'Cadastrar';
      }
    });
  }

  // =========================================================================
  // LOGIN
  // =========================================================================
  if (loginForm) {
    // -- Pre-fill fields if the user just completed registration --
    const prefillWhats = sessionStorage.getItem('prefillWhats');
    const prefillSenha = sessionStorage.getItem('prefillSenha');

    if (prefillWhats && document.getElementById('loginWhats')) {
      document.getElementById('loginWhats').value = prefillWhats;
      sessionStorage.removeItem('prefillWhats');
    }
    if (prefillSenha && document.getElementById('loginSenha')) {
      document.getElementById('loginSenha').value = prefillSenha;
      sessionStorage.removeItem('prefillSenha');
    }

    loginForm.addEventListener('submit', async (event) => {
      event.preventDefault();

      const btnSubmit = loginForm.querySelector('button[type="submit"]');
      btnSubmit.disabled    = true;
      btnSubmit.textContent = 'Entrando...';

      try {
        const whatsRaw = document.getElementById('loginWhats').value.trim();
        const senhaRaw = document.getElementById('loginSenha').value;

        const whatsapp  = normalizarWhats(whatsRaw);
        const authEmail = `${whatsapp}@vanguard.app`;

        // Hash the entered password for comparison against the stored hash
        const senhaHash = await hashSenha(senhaRaw);

        // -- Sign in via Supabase Auth --
        const { error: signInError } = await window._supabase.auth.signInWithPassword({
          email:    authEmail,
          password: senhaRaw,
        });

        if (signInError) {
          alert('WhatsApp ou senha inválidos. Verifique os dados e tente novamente.');
          btnSubmit.disabled    = false;
          btnSubmit.textContent = 'Entrar';
          return;
        }

        // -- Fetch the user profile from the usuarios table --
        const { data: rows, error: fetchError } = await window._supabase
          .from('usuarios')
          .select('*')
          .eq('whatsapp', whatsapp);

        if (fetchError) throw new Error(fetchError.message);

        // Extra safety: validate the stored hash matches what the user entered
        const usuario = (rows || []).find(u => u.senha === senhaHash);

        if (!usuario) {
          alert('WhatsApp ou senha inválidos. Verifique os dados e tente novamente.');
          btnSubmit.disabled    = false;
          btnSubmit.textContent = 'Entrar';
          return;
        }

        // Persist the logged-in user profile and redirect
        localStorage.setItem('logado', JSON.stringify(usuario));

        if (usuario.admin) {
          window.location.href = 'admin.html';
        } else {
          window.location.href = 'cliente.html';
        }

      } catch (e) {
        console.error('[auth.js] Erro ao fazer login:', e);
        alert('Erro ao fazer login: ' + e.message);
        btnSubmit.disabled    = false;
        btnSubmit.textContent = 'Entrar';
      }
    });
  }
});
