import PhoneFrame from "./PhoneFrame";
import HomeMock from "./mocks/HomeMock";
import TripsMock from "./mocks/TripsMock";
import NearbyMock from "./mocks/NearbyMock";

const screens = [
  { mock: <HomeMock />, title: "Dashboard", description: "Your next trip, weather, and calendar at a glance." },
  { mock: <TripsMock />, title: "Trips", description: "Every trip you're planning, with a live countdown." },
  { mock: <NearbyMock />, title: "Nearby Travelers", description: "Opt in and meet other travelers around you." },
];

export default function PhoneMockups() {
  return (
    <section id="mockups" className="bg-teal-dark py-24 text-white">
      <div className="mx-auto max-w-6xl px-6">
        <div className="mx-auto max-w-2xl text-center">
          <p className="text-sm font-bold uppercase tracking-widest text-amber">
            Take a look inside
          </p>
          <h2 className="mt-3 text-3xl font-extrabold tracking-tight md:text-4xl">
            Built for the way you actually travel
          </h2>
        </div>

        <div className="mt-16 grid grid-cols-1 gap-16 sm:grid-cols-2 lg:grid-cols-3">
          {screens.map(({ mock, title, description }) => (
            <div key={title} className="flex flex-col items-center text-center">
              <PhoneFrame>{mock}</PhoneFrame>
              <h3 className="mt-8 font-bold">{title}</h3>
              <p className="mt-1 max-w-[240px] text-sm text-white/60">{description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
