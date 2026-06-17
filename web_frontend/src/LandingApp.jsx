import Navbar from './components/Navbar';
import Hero from './components/Hero';
import Problem from './components/Problem';
import Solution from './components/Solution';
import HowItWorks from './components/HowItWorks';
import Features from './components/Features';
import Models from './components/Models';
import About from './components/About';
import Impact from './components/Impact';
import Roadmap from './components/Roadmap';
import ComingSoon from './components/ComingSoon';
import Download from './components/Download';
import Footer from './components/Footer';
import { SectionDivider } from './utils/motion';

export default function LandingApp() {
  return (
    <div className="min-h-screen bg-[#fafafa]">
      <Navbar />
      <main>
        <Hero />
        <SectionDivider />
        <Problem />
        <SectionDivider />
        <Solution />
        <SectionDivider />
        <HowItWorks />
        <SectionDivider />
        <Features />
        <SectionDivider />
        <Models />
        <SectionDivider />
        <About />
        <Impact />
        <SectionDivider />
        <Roadmap />
        <SectionDivider />
        <ComingSoon />
        <SectionDivider />
        <Download />
      </main>
      <Footer />
    </div>
  );
}
