import Navbar from './components/Navbar/Navbar'
import Hero from './components/Hero/Hero'
import Features from './components/Features/Features'
import HowItWorks from './components/HowItWorks/HowItWorks'
import Showcase from './components/Showcase/Showcase'
import Download from './components/Download/Download'
import Footer from './components/Footer/Footer'

function App() {
  return (
    <div className="min-h-screen bg-void">
      {/* Film grain texture */}
      <div className="grain-overlay" />

      <Navbar />
      <Hero />
      <Features />
      <HowItWorks />
      <Showcase />
      <Download />
      <Footer />
    </div>
  )
}

export default App
