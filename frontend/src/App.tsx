import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Layout } from './components/layout/Layout';
import { Header } from './components/Header';
import { VotingForm } from './components/VotingForm';
import { LeaderboardTable } from './components/LeaderboardTable';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 2,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 1,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Layout>
        <Header />
        <div className="w-3/4 mx-auto">
          <VotingForm />
          <LeaderboardTable />
        </div>
      </Layout>
    </QueryClientProvider>
  );
}

export default App;
