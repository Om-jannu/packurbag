export default function Cta() {
  return (
    <section className="mx-auto max-w-6xl px-6 py-24">
      <div className="relative overflow-hidden rounded-[2.5rem] bg-coral px-8 py-16 text-center text-white">
        <div
          className="pointer-events-none absolute inset-0 opacity-25"
          style={{
            background:
              "radial-gradient(50% 60% at 85% 20%, var(--color-amber) 0%, transparent 60%)",
          }}
        />
        <div className="relative">
          <h2 className="text-3xl font-extrabold tracking-tight md:text-4xl">
            Ready to pack your bag?
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-white/85">
            Packurbag is currently in development for iOS and Android. Leave your
            email and we&apos;ll let you know the moment it launches.
          </p>
          <form className="mx-auto mt-8 flex max-w-md flex-col gap-3 sm:flex-row">
            <input
              type="email"
              required
              placeholder="you@example.com"
              className="flex-1 rounded-full bg-white/95 px-5 py-3.5 text-sm font-medium text-teal-dark placeholder:text-black/40 focus:outline-none focus:ring-2 focus:ring-white"
            />
            <button
              type="submit"
              className="rounded-full bg-teal-dark px-6 py-3.5 text-sm font-bold text-white transition hover:brightness-110"
            >
              Notify me
            </button>
          </form>
        </div>
      </div>
    </section>
  );
}
