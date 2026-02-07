export const theme = {
  colors: {
    violet: '#8B5CF6',
    violetLight: '#A87CF6',
    violetDark: '#7C3AED',
    void: '#08080C',
    voidLight: '#0D0D14',
    surface: '#13131A',
    card: '#15151E',
    cardHover: '#1C1C27',
    border: 'rgba(139, 92, 246, 0.12)',
    borderHover: 'rgba(139, 92, 246, 0.25)',
    textPrimary: '#EBEBEF',
    textSecondary: '#83839A',
    textDim: '#525266',
  },
  gradients: {
    violet: 'linear-gradient(135deg, #8B5CF6 0%, #A87CF6 50%, #7C3AED 100%)',
    glow: 'radial-gradient(ellipse at center, rgba(139, 92, 246, 0.15) 0%, transparent 70%)',
    surface: 'linear-gradient(180deg, #0D0D14 0%, #08080C 100%)',
    card: 'linear-gradient(135deg, #15151E 0%, #13131A 100%)',
  },
} as const;

export type Theme = typeof theme;
