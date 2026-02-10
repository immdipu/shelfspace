import { motion } from 'framer-motion'

const ease = [0.22, 1, 0.36, 1]

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

const ShowcaseCard = ({ item, index }: { item: { label: string; description: string; image: string }; index: number }) => (
  <motion.div
    initial={{ opacity: 0, y: 24 }}
    whileInView={{ opacity: 1, y: 0 }}
    viewport={{ once: true, margin: "-60px" }}
    transition={{ delay: index * 0.1, duration: 0.6, ease }}
    className="group"
  >
    <div className="glass-card rounded-2xl overflow-hidden mb-4 transition-all duration-500">
      <div className="aspect-[4/3] bg-void-200 relative overflow-hidden">
        <img
          src={item.image}
          alt={item.label}
          className="w-full h-full object-cover object-top"
          loading="lazy"
        />
        <div className="absolute inset-x-0 bottom-0 h-12 bg-gradient-to-t from-void-200 to-transparent pointer-events-none" />
      </div>
    </div>
    <h3 className="font-body text-base font-semibold text-ash-50 mb-1">{item.label}</h3>
    <p className="font-body text-sm text-ash-500">{item.description}</p>
  </motion.div>
)

const Showcase = () => {
  return (
    <section id="showcase" className="relative py-32 px-4">
      <div className="section-divider max-w-2xl mx-auto mb-32" />

      <div className="max-w-6xl mx-auto relative">
        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-80px" }}
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
            Whether you prefer visual grids or lean lists, ShelfSpace adapts to how you work.
          </p>
        </motion.div>

        {/* App views — top row of 3, bottom row of 2 centered */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          {appViews.slice(0, 3).map((item, i) => (
            <ShowcaseCard key={item.label} item={item} index={i} />
          ))}
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mt-5 max-w-[calc(66.666%+0.625rem)] mx-auto">
          {appViews.slice(3).map((item, i) => (
            <ShowcaseCard key={item.label} item={item} index={i} />
          ))}
        </div>

        {/* Settings sub-header */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-60px" }}
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

        {/* Settings views — 3 columns */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          {settingsViews.map((item, i) => (
            <ShowcaseCard key={item.label} item={item} index={i} />
          ))}
        </div>

        {/* Stats bar */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-60px" }}
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
              <div className="font-display text-3xl md:text-4xl text-ash-50 tracking-tight">{stat.value}</div>
              <div className="font-body text-sm text-ash-500 mt-1">{stat.label}</div>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}

export default Showcase
