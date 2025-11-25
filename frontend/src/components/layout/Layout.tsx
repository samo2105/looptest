import type { ReactNode } from 'react';
import { Container } from './Container';

interface LayoutProps {
  children: ReactNode;
}

export const Layout = ({ children }: LayoutProps) => {
  return (
    <div className="min-h-screen bg-bg-light">
      <Container>
        <div className="min-h-screen p-4 sm:p-6">
          {children}
        </div>
      </Container>
    </div>
  );
};

