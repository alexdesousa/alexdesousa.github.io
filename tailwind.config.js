module.exports = {
  content: [
    './_layouts/**/*.html',
    './_includes/**/*.html',
    './*.html',
    './_posts/**/*.md',
  ],
  theme: {
    extend: {
      fontFamily: { mono: ['"Space Mono"', '"Courier New"', 'Courier', 'monospace'] },
      colors: {
        canvas: 'var(--bg)',
        ink:    'var(--fg)',
        card:   'var(--card)',
        pri:    'var(--primary)',
        accent: 'var(--accent)',
        brdr:   'var(--border)',
        muted:  'var(--muted-fg)',
      },
      boxShadow: {
        'neo-sm':   '2px 2px 0 var(--shadow)',
        'neo':      '4px 4px 0 var(--shadow)',
        'neo-lg':   '6px 6px 0 var(--shadow)',
        'neo-3':    '3px 3px 0 var(--shadow)',
        'neo-none': '0 0 0 var(--shadow)',
      },
    },
  },
  plugins: [],
}
