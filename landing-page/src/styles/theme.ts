export const theme = {
  colors: {
    primary: '#3366E6',
    primaryLight: '#4D80F2',
    primaryDark: '#264DCC',
    accent: '#E64D80',
    background: '#1a1a2e',
    backgroundLight: '#16213e',
    surface: '#0f3460',
    textPrimary: '#ffffff',
    textSecondary: '#a0aec0',
  },
  gradients: {
    primary: 'linear-gradient(135deg, #3366E6 0%, #E64D80 100%)',
    background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
  },
} as const;

export type Theme = typeof theme;
