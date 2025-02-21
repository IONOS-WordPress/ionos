document.querySelectorAll('.ionos-dashboard-nba a').forEach((link) => {
  link.addEventListener('click', (event) => {
    event.preventDefault();

    wp.ajax
      .send('execute-nba-callback', {
        type: 'GET',
        data: {
          process: link.getAttribute('callback-id'),
          id: link.getAttribute('data-id'),
        },
      })
      .then((response) => {
        if (response.redirect !== undefined) {
          window.top.location.href = response.redirect;
        }
        if (response.addClass !== undefined) {
          link.classList.add(response.addClass);
        }
      });
  });
});
