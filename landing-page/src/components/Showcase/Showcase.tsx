import {
  motion,
  useMotionTemplate,
  useMotionValue,
  useSpring,
  useTransform,
} from 'framer-motion'
import { useRef, useCallback } from 'react'

const ease = [0.16, 1, 0.3, 1]

const appViews = [
  {
    label: 'All Items',
    description: 'Grid view with all clipboard items — images, text, and files at a glance.',
    image: '/images/showcase/image_all_tab.png',
  },
  {
    label: 'Images Tab',
    description: 'Filter to see only captured images with rich, full-size previews.',
    image: '/images/showcase/image_images_tab.png',
  },
  {
    label: 'Text Tab',
    description: 'Quickly find copied text snippets with inline content previews.',
    image: '/images/showcase/image_text_tab.png',
  },
  {
    label: 'List View',
    description: 'Compact rows for quick scanning with type icons, names, and metadata.',
    image: '/images/showcase/image_list_view.png',
  },
  {
    label: 'Pinned Items',
    description: 'Pin important clipboard items so they never get pushed out.',
    image: '/images/showcase/image_pinned.png',
  },
]

const settingsViews = [
  {
    label: 'General',
    description: 'System preferences — menu bar icon, launch at login, and dock visibility.',
    image: '/images/showcase/settings_general.png',
  },
  {
    label: 'Appearance',
    description: 'Grid density, thumbnail style, card corners, and visual tweaks.',
    image: '/images/showcase/settings_appearance.png',
  },
  {
    label: 'Clipboard',
    description: 'Monitoring, capture types, polling interval, and storage limits.',
    image: '/images/showcase/settings_clipboard.png',
  },
]

/* ─── 3D Tilt Card with Cursor-Reactive Effects ─── */

const TiltCard = ({
  item,
  globalIndex,
}: {
  item: { label: string; description: string; image: string }
  globalIndex: number
}) => {
  const ref = useRef<HTMLDivElement>(null)

  // Normalized cursor position (-0.5 to 0.5)
  const mouseX = useMotionValue(0)
  const mouseY = useMotionValue(0)

  // Spring-damped 3D rotation
  const rotateX = useSpring(useTransform(mouseY, [-0.5, 0.5], [10, -10]), {
    stiffness: 200,
    damping: 20,
  })
  const rotateY = useSpring(useTransform(mouseX, [-0.5, 0.5], [-10, 10]), {
    stiffness: 200,
    damping: 20,
  })

  // Image parallax — moves opposite to tilt for depth
  const imgX = useSpring(useTransform(mouseX, [-0.5, 0.5], [12, -12]), {
    stiffness: 120,
    damping: 18,
  })
  const imgY = useSpring(useTransform(mouseY, [-0.5, 0.5], [12, -12]), {
    stiffness: 120,
    damping: 18,
  })

  // Cursor glow position (0–100%)
  const glowX = useMotionValue(50)
  const glowY = useMotionValue(50)

  const glowFill = useMotionTemplate`radial-gradient(300px circle at ${glowX}% ${glowY}%, rgba(139,92,246,0.12), transparent 60%)`
  const glowEdge = useMotionTemplate`radial-gradient(400px circle at ${glowX}% ${glowY}%, rgba(139,92,246,0.35), transparent 60%)`
  const specular = useMotionTemplate`radial-gradient(180px circle at ${glowX}% ${glowY}%, rgba(255,255,255,0.06), transparent 60%)`

  const onMove = useCallback(
    (e: React.MouseEvent) => {
      const r = ref.current?.getBoundingClientRect()
      if (!r) return
      const px = (e.clientX - r.left) / r.width - 0.5
      const py = (e.clientY - r.top) / r.height - 0.5
      mouseX.set(px)
      mouseY.set(py)
      glowX.set((px + 0.5) * 100)
      glowY.set((py + 0.5) * 100)
    },
    [mouseX, mouseY, glowX, glowY],
  )

  const onLeave = useCallback(() => {
    mouseX.set(0)
    mouseY.set(0)
    glowX.set(50)
    glowY.set(50)
  }, [mouseX, mouseY, glowX, glowY])

  return (
    /* Entrance: cards emerge from depth with perspective rotation */
    <motion.div
      initial={{ opacity: 0, y: 80, rotateX: 20, scale: 0.88 }}
      whileInView={{ opacity: 1, y: 0, rotateX: 0, scale: 1 }}
      viewport={{ once: true, margin: '-100px' }}
      transition={{ delay: globalIndex * 0.1, duration: 0.9, ease }}
      style={{ perspective: 800 }}
    >
      {/* Tilt container — rotates on cursor move */}
      <motion.div
        ref={ref}
        onMouseMove={onMove}
        onMouseLeave={onLeave}
        style={{ rotateX, rotateY, transformStyle: 'preserve-3d' }}
        className="group cursor-pointer"
      >
        <div className="relative rounded-2xl mb-4">
          {/* Dynamic glow border — masked to 1px edge, follows cursor */}
          <motion.div
            className="absolute -inset-px rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 z-20 pointer-events-none"
            style={
              {
                background: glowEdge,
                WebkitMask:
                  'linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)',
                WebkitMaskComposite: 'xor',
                maskComposite: 'exclude',
                padding: '1px',
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
              } as any
            }
          />

          <motion.div
            className="absolute inset-0 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 z-10 pointer-events-none"
            style={{ background: glowFill }}
          />

          <div className="glass-card rounded-2xl overflow-hidden transition-shadow duration-500 group-hover:shadow-[0_25px_60px_-12px_rgba(139,92,246,0.25)]">
            <div className="aspect-[4/3] bg-void-200 relative overflow-hidden">
              <motion.img
                src={item.image}
                alt={item.label}
                className="w-full h-full object-cover object-top"
                style={{ x: imgX, y: imgY, scale: 1.12 }}
                loading="lazy"
              />

              {/* Specular highlight — follows cursor inside image */}
              <motion.div
                className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none mix-blend-overlay"
                style={{ background: specular }}
              />

              <div className="absolute inset-x-0 bottom-0 h-16 bg-gradient-to-t from-void-200 to-transparent pointer-events-none" />
            </div>
          </div>
        </div>

        <h3 className="font-body text-base font-semibold text-ash-50 mb-1 group-hover:text-violet-200 transition-colors duration-300">
          {item.label}
        </h3>
        <p className="font-body text-sm text-ash-500">{item.description}</p>
      </motion.div>
    </motion.div>
  )
}

/* ─── Floating Ambient Orbs ─── */

const FloatingOrbs = () => (
  <div className="absolute inset-0 overflow-hidden pointer-events-none">
    <motion.div
      className="absolute w-[500px] h-[500px] rounded-full"
      style={{
        background:
          'radial-gradient(circle, rgba(139,92,246,0.06) 0%, transparent 70%)',
        left: '10%',
        top: '20%',
      }}
      animate={{ y: [0, -30, 0], x: [0, 15, 0] }}
      transition={{ duration: 12, repeat: Infinity, ease: 'easeInOut' }}
    />
    <motion.div
      className="absolute w-[400px] h-[400px] rounded-full"
      style={{
        background:
          'radial-gradient(circle, rgba(139,92,246,0.04) 0%, transparent 70%)',
        right: '5%',
        top: '50%',
      }}
      animate={{ y: [0, 25, 0], x: [0, -20, 0] }}
      transition={{ duration: 15, repeat: Infinity, ease: 'easeInOut' }}
    />
    <motion.div
      className="absolute w-[350px] h-[350px] rounded-full"
      style={{
        background:
          'radial-gradient(circle, rgba(139,92,246,0.05) 0%, transparent 70%)',
        left: '40%',
        bottom: '10%',
      }}
      animate={{ y: [0, -20, 0], x: [0, 10, 0] }}
      transition={{
        duration: 10,
        repeat: Infinity,
        ease: 'easeInOut',
        delay: 2,
      }}
    />
  </div>
)

/* ─── Main Showcase Section ─── */

const Showcase = () => {
  const sectionRef = useRef<HTMLElement>(null)

  // Section-wide cursor spotlight
  const spotX = useMotionValue(-1000)
  const spotY = useMotionValue(-1000)
  const smoothX = useSpring(spotX, { stiffness: 30, damping: 20 })
  const smoothY = useSpring(spotY, { stiffness: 30, damping: 20 })
  const spotlightBg = useMotionTemplate`radial-gradient(1000px circle at ${smoothX}px ${smoothY}px, rgba(139,92,246,0.035), transparent 45%)`

  const onSectionMove = useCallback(
    (e: React.MouseEvent) => {
      const r = sectionRef.current?.getBoundingClientRect()
      if (!r) return
      spotX.set(e.clientX - r.left)
      spotY.set(e.clientY - r.top)
    },
    [spotX, spotY],
  )

  return (
    <section
      ref={sectionRef}
      onMouseMove={onSectionMove}
      id="showcase"
      className="relative py-32 px-4"
    >
      {/* Ambient floating orbs */}
      <FloatingOrbs />

      <motion.div
        className="absolute inset-0 pointer-events-none z-0"
        style={{ background: spotlightBg }}
      />

      <div className="section-divider max-w-2xl mx-auto mb-32" />

      <div className="max-w-6xl mx-auto relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-80px' }}
          transition={{ duration: 0.7, ease }}
          className="text-center mb-20"
        >
          <span className="inline-block font-mono text-xs text-violet tracking-widest uppercase mb-4">
            Showcase
          </span>
          <h2 className="font-display text-4xl md:text-6xl tracking-tight mb-5">
            <span className="text-ash-50">Crafted for</span>{' '}
            <span className="text-ash-400 italic">every workflow.</span>
          </h2>
          <p className="font-body text-lg text-ash-500 max-w-lg mx-auto">
            Whether you prefer visual grids or lean lists, ShelfSpace adapts to
            how you work.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          {appViews.slice(0, 3).map((item, i) => (
            <TiltCard key={item.label} item={item} globalIndex={i} />
          ))}
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mt-5 max-w-[calc(66.666%+0.625rem)] mx-auto">
          {appViews.slice(3).map((item, i) => (
            <TiltCard key={item.label} item={item} globalIndex={i} />
          ))}
        </div>

        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-60px' }}
          transition={{ duration: 0.6, ease }}
          className="text-center mt-20 mb-10"
        >
          <span className="inline-block font-mono text-xs text-ash-500 tracking-widest uppercase mb-3">
            Settings
          </span>
          <h3 className="font-display text-2xl md:text-3xl tracking-tight text-ash-50">
            Fine-tuned <span className="text-ash-400 italic">control.</span>
          </h3>
        </motion.div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          {settingsViews.map((item, i) => (
            <TiltCard key={item.label} item={item} globalIndex={i} />
          ))}
        </div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-60px' }}
          transition={{ duration: 0.7, ease }}
          className="mt-20 glass-card rounded-2xl p-8 flex flex-col sm:flex-row items-center justify-around gap-8"
        >
          {[
            { value: '200MB', label: 'Max file size' },
            { value: '1000+', label: 'Items stored' },
            { value: '0.5s', label: 'Polling interval' },
            { value: 'Native', label: 'Swift & AppKit' },
          ].map((stat, i) => (
            <div key={i} className="text-center">
              <div className="font-display text-3xl md:text-4xl text-ash-50 tracking-tight">
                {stat.value}
              </div>
              <div className="font-body text-sm text-ash-500 mt-1">
                {stat.label}
              </div>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}

export default Showcase
