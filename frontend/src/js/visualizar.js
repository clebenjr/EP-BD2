const ctx = document.getElementById('myChart');

new Chart(ctx, {
  type: 'bar',
  data: {
    labels: ['Etnia', 'Matérias Primas', 'Religiões', 'Regiões'],
    datasets: [{
      label: 'Números de Conflitos',
      data: [2, 1, 0, 3],
      borderWidth: 1
    }]
  },
  options: {
    scales: {
      y: {
        beginAtZero: true
      }
    }
  }
});