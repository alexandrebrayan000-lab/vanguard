// js/supabase-client.js
// Inicialização centralizada do cliente Supabase
// Incluir este script ANTES de qualquer outro script que use o Supabase

const SUPABASE_URL = 'https://pjwrkecbcddnqfajjgjr.supabase.co';
const SUPABASE_KEY = 'sb_publishable_oyWF1sCKBgjqQMic7acIUg_HZnXAiSP';

// Inicializa o cliente global
const { createClient } = supabase;
window._supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

// Constantes auxiliares para uso via REST API (fetch direto em admin.js, cliente.js, main.js)
window.SUPABASE_URL_REST = SUPABASE_URL + '/rest/v1';
window.SUPABASE_ANON_KEY  = SUPABASE_KEY;
