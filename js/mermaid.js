import mermaid from 'mermaid';

function getTheme() {
  return document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'default';
}

function renderDiagrams() {
  mermaid.initialize({ startOnLoad: false, theme: getTheme(), useMaxWidth: true });
  document.querySelectorAll('.mermaid').forEach(function(el) {
    if (el.dataset.source) {
      el.removeAttribute('data-processed');
      el.textContent = el.dataset.source;
    }
  });
  mermaid.run();
}

document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('pre code.language-mermaid').forEach(function(el) {
    var div = document.createElement('div');
    div.className = 'mermaid';
    div.textContent = el.textContent;
    el.closest('pre').replaceWith(div);
  });

  document.querySelectorAll('.mermaid').forEach(function(el) {
    el.dataset.source = el.textContent.trim();
  });

  renderDiagrams();

  var originalToggle = window.toggleTheme;
  window.toggleTheme = function() {
    originalToggle();
    renderDiagrams();
  };
});
