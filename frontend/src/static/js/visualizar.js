const ctx = document.getElementById('myChart');

const maxValue = Math.max(...[graf[0][1], graf[1][1], graf[2][1], graf[3][1]]);
const suggestedMax = Math.ceil(maxValue * 1.1);

new Chart(ctx, {
  type: 'bar',
  data: {
    labels: [graf[0][0], graf[1][0], graf[2][0], graf[3][0]],
    datasets: [{
      label: 'Números de Conflitos',
      data: [graf[0][1], graf[1][1], graf[2][1], graf[3][1]],
      borderWidth: 1,
      backgroundColor: '#7d9900',
      borderColor: '#5f663e',
    }]
  },
  options: {
    scales: {
      y: {
        beginAtZero: true,
        suggestedMax: suggestedMax,
      }
    }
  }
});