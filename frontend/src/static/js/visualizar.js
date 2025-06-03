const ctx = document.getElementById('myChart');

new Chart(ctx, {
  type: 'bar',
  data: {
    labels: ['Etnia', 'Matérias Primas', 'Religiões', 'Regiões'],
    datasets: [{
      label: 'Números de Conflitos',
      data: [2, 1, 0, 3],
      borderWidth: 1,
      backgroundColor: '#7d9900',
      borderColor: '#5f663e',
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