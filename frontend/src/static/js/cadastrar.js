function adicionarTipo() {
  const opcoesDiv = document.getElementById('tipo-conflito-opcoes');
  const novoCampo = document.createElement('div');
  novoCampo.innerHTML = `
  <div class="campo-tipo-conflito">
      <select class="tipo-conflito">
          <option value="materia-prima">Matéria Prima</option>
          <option value="regiao">Região</option>
          <option value="religiao">Religião</option>
          <option value="etnia">Etnia</option>
      </select>
      <input type="text" class="descricao-conflito" placeholder="Nome do Conflito" /> 
      <button class="remover-tipo" onclick="this.parentElement.remove()"><img width="24" height="24" src="https://img.icons8.com/material-rounded/24/trash.png" alt="trash"/>Remover</button>
  </div>
  `;
  opcoesDiv.appendChild(novoCampo);
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


function redirecionarCadastro() {
  const tipo = document.getElementById('tipo').value;
  // Redireciona para a rota correspondente
  window.location.href = `/cadastrar/${tipo}`;
}