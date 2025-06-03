function adicionarTipo() {
  alert("Função para adicionar novo tipo de conflito.");
}

function adicionarConflito() {
  const nome = document.getElementById("nome").value;
  const mortos = document.getElementById("mortos").value;
  const feridos = document.getElementById("feridos").value;

  if (!nome || !mortos || !feridos) {
    alert("Por favor, preencha todos os campos obrigatórios.");
    return;
  }

  alert(`Conflito "${nome}" adicionado com sucesso!`);
}
