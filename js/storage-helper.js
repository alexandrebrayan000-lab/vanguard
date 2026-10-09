// js/storage-helper.js
// Helper para upload de imagens no Supabase Storage
// Substitui o armazenamento de Base64 no banco de dados

/**
 * Faz upload de um arquivo para o bucket 'fotos' no Supabase Storage.
 * Retorna a URL pública da imagem ou null em caso de falha.
 *
 * @param {File} file - O arquivo de imagem selecionado pelo usuário
 * @param {string} pasta - Subpasta dentro do bucket (ex: 'servicos', 'barbeiros', 'produtos', 'perfil', 'galeria')
 * @returns {Promise<string|null>} URL pública da imagem ou null
 */
async function uploadFoto(file, pasta = 'geral') {
  try {
    const ext = file.name.split('.').pop();
    const nomeUnico = `${pasta}/${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`;

    const { data, error } = await window._supabase.storage
      .from('fotos')
      .upload(nomeUnico, file, {
        cacheControl: '3600',
        upsert: false,
        contentType: file.type
      });

    if (error) {
      console.error('[storage-helper] Erro no upload:', error.message);
      return null;
    }

    const { data: urlData } = window._supabase.storage
      .from('fotos')
      .getPublicUrl(data.path);

    return urlData.publicUrl;
  } catch (err) {
    console.error('[storage-helper] Erro inesperado:', err);
    return null;
  }
}

/**
 * Resolve a URL da imagem: faz upload se for um File novo,
 * retorna a URL já existente se for string, ou null se não houver imagem.
 *
 * @param {string} inputId - ID do input[type=file]
 * @param {string} pasta - Subpasta no bucket
 * @param {string} [urlAtual] - URL atual da imagem (para edição, preservar se não mudar)
 * @returns {Promise<string|null>}
 */
async function resolveImagemStorage(inputId, pasta, urlAtual = null) {
  const input = document.getElementById(inputId);
  const file = input?.files?.[0];

  if (file) {
    // Nova imagem selecionada — faz upload
    return await uploadFoto(file, pasta);
  }

  // Sem nova imagem — retorna a URL atual (ou null se não houver)
  return urlAtual || null;
}
