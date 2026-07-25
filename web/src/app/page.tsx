import Hero from "@/components/Hero";
import Features from "@/components/Features";
import PhoneMockups from "@/components/PhoneMockups";
import Cta from "@/components/Cta";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <div className="flex flex-col">
      <Hero />
      <Features />
      <PhoneMockups />
      <Cta />
      <Footer />
    </div>
  );
}
