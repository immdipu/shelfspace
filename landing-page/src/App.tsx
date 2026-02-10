import Navbar from './components/Navbar/Navbar'
import Hero from './components/Hero/Hero'
import Features from './components/Features/Features'
import HowItWorks from './components/HowItWorks/HowItWorks'
import Showcase from './components/Showcase/Showcase'
import Installation from './components/Installation/Installation'
import Download from './components/Download/Download'
import Footer from './components/Footer/Footer'

function App() {
  return (
    <div className="min-h-screen bg-void">
      <div className="grain-overlay" />
      <Navbar />
      <Hero />
      <Features />
      <HowItWorks />
      <Showcase />
      <Installation />
      <Download />
      <Footer />
    </div>
  )
}

export default App
