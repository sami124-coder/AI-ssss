import React from 'react';
import ReactDOM from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter } from 'react-router-dom';
import './styles.css';

const queryClient = new QueryClient();
function App() {
  const language = navigator.language.startsWith('ar') ? 'ar' : 'en';
  const copy = language === 'ar'
    ? { title: 'ذكاء قرارات المطاعم', body: 'حوّل بيانات التشغيل إلى قرار واحد قابل للقياس.' }
    : { title: 'Restaurant Decision AI', body: 'Turn operational data into one measurable decision.' };
  return <main dir={language === 'ar' ? 'rtl' : 'ltr'}><p className="eyebrow">PILOT</p><h1>{copy.title}</h1><p>{copy.body}</p></main>;
}
ReactDOM.createRoot(document.getElementById('root')!).render(<React.StrictMode><BrowserRouter><QueryClientProvider client={queryClient}><App /></QueryClientProvider></BrowserRouter></React.StrictMode>);
