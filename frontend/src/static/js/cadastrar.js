function adicionarTipo() {
  const opcoesDiv = document.getElementById('tipo-conflito-opcoes');
  const novoCampo = document.createElement('div');
  novoCampo.innerHTML = `
  <div class="campo-tipo-conflito">
      <select name="tipo" class="tipo-conflito">
          <option value="materia-prima">Matéria Prima</option>
          <option value="regiao">Região</option>
          <option value="religiao">Religião</option>
          <option value="etnia">Etnia</option>
      </select>
      <input type="text" name="conflitos" class="descricao-conflito" placeholder="Nome do Conflito" /> 
      <button type="button" class="remover-tipo" onclick="this.parentElement.remove()"><img width="24" height="24" src="https://img.icons8.com/material-rounded/24/trash.png" alt="trash"/>Remover</button>
  </div>
  `;
  opcoesDiv.appendChild(novoCampo);
}

function redirecionarCadastro() {
  const tipo = document.getElementById('tipo').value;
  window.location.href = `/cadastrar/${tipo}`;
}

function filtrarInputSomenteNumeros(campo) {
  const valorAntigo = campo.value;
  const posCursor = campo.selectionStart;

  const valorFiltrado = valorAntigo.replace(/[^0-9]/g, "");

  if (valorAntigo !== valorFiltrado) {
    campo.value = valorFiltrado;
    const novaPos = Math.min(posCursor - 1, valorFiltrado.length);
    campo.setSelectionRange(novaPos, novaPos);
  } 
}

document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('input[type="number"]').forEach(element => {
    element.addEventListener('input', function () {
      const valorAntigo = this.value;
      const posCursor = this.selectionStart;
      const valorFiltrado = valorAntigo.replace(/[^0-9]/g, '');

      if (valorAntigo !== valorFiltrado) {
        setTimeout(() => {
          this.value = valorFiltrado;
          const novaPos = posCursor - (valorAntigo.length - valorFiltrado.length);
          this.setSelectionRange(novaPos, novaPos);
        }, 0);
      }
    });
  });
});



function fecharAlerta(elem) {
  elem.parentElement.style.display='none';
  document.getElementById('alert-overlay').style.display = 'none';
}