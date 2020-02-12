/**
 * Handles external links.
 */
function handleExternalLinks() {
  const host = location.hostname;
  const links = document.querySelectorAll('a');

  for (var i = 0; i < links.length; ++i) {
    let link = links[i];

    if (link.hostname !== host && link.hostname !== '') {
      link.target = '_blank';
    }
  }
}

window.onload = handleExternalLinks;
