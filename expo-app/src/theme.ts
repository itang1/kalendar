import { useColorScheme } from 'react-native';

export interface Theme {
  dark: boolean;
  /** Behind the grid and wheel; the iPhone app's `kalendarBackground`. */
  canvas: string;
  /** Sheets and cards. */
  surface: string;
  text: string;
  muted: string;
  hairline: string;
  chip: string;
  star: string;
}

const light: Theme = {
  dark: false,
  canvas: '#C7CCD6',
  surface: '#FFFFFF',
  text: '#111114',
  muted: '#5F6170',
  hairline: 'rgba(0,0,0,0.12)',
  chip: 'rgba(0,0,0,0.07)',
  star: '#E0B000',
};

const dark: Theme = {
  dark: true,
  canvas: '#1F2129',
  surface: '#1A1A21',
  text: '#F4F4F6',
  muted: '#A0A0AD',
  hairline: 'rgba(255,255,255,0.12)',
  chip: 'rgba(255,255,255,0.1)',
  star: '#E0C235',
};

export function useTheme(): Theme {
  return useColorScheme() === 'dark' ? dark : light;
}
