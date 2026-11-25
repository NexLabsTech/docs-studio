import React from "react";
import { Composition, Img, interpolate, staticFile, useCurrentFrame } from "remotion";

const Smoke = () => {
  const frame = useCurrentFrame();
  const shift = interpolate(frame, [0, 299], [-18, 18]);
  return (
    <main style={{
      alignItems: "center",
      background: "linear-gradient(135deg, #0b1020, #243b55)",
      color: "#ffffff",
      display: "flex",
      fontFamily: "Arial, sans-serif",
      height: "100%",
      justifyContent: "center",
      width: "100%"
    }}>
      <section style={{ alignItems: "center", display: "flex", gap: 48 }}>
        <Img src={staticFile("import-fixture.png")} style={{
          borderRadius: 24,
          height: 240,
          transform: `translateY(${shift}px)`,
          width: 240
        }} />
        <div>
          <div style={{ color: "#75e0c1", fontSize: 28, letterSpacing: 4 }}>NDS CORE</div>
          <h1 style={{ fontSize: 64, margin: "16px 0" }}>Local render check</h1>
          <p style={{ color: "#c5d1e0", fontSize: 30 }}>Synthetic 10-second fixture</p>
        </div>
      </section>
    </main>
  );
};

export const SmokeRoot = () => (
  <Composition
    id="nds-core-smoke"
    component={Smoke}
    durationInFrames={300}
    fps={30}
    height={1080}
    width={1920}
  />
);
