import Image from "next/image";

export default function SplashMock() {
  return (
    <div className="flex h-full flex-col items-center justify-center gap-4 bg-white">
      <div className="animate-float">
        <Image src="/packurbag-logo.png" alt="Packurbag" width={72} height={72} />
      </div>
      <p className="text-[15px] font-extrabold text-teal-dark">Packurbag</p>
    </div>
  );
}
