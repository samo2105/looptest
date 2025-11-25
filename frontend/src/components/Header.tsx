import loopstudioLogo from '../assets/loopstudio.png';

export const Header = () => {
  return (
    <header className="flex flex-col sm:flex-row items-center gap-4 pb-4 mb-6">
      {/* Loopstudio Logo */}
      <div className="flex items-center gap-3">
        <img
          src={loopstudioLogo}
          alt="loopstudio logo"
          className="flex-shrink-0 h-8 w-auto"
        />
        <span className="text-base sm:text-lg font-semibold text-text-primary">
          loopstudio
        </span>
      </div>

      {/* Vertical separator */}
      <div className="h-6 w-px bg-border-grey hidden sm:block" />

      {/* Challenge text */}
      <span className="text-xs sm:text-sm text-text-secondary">
        Frontend Developer Challenge
      </span>
    </header>
  );
};

