import { motion } from 'framer-motion'

const ease = [0.22, 1, 0.36, 1]

const showcaseItems = [
  {
    label: 'Grid View',
    description: '2-column grid with rich image previews, text rendering, and file type icons.',
  },
  {
    label: 'List View',
    description: 'Compact rows for quick scanning with type icons, names, and metadata.',
  },
  {
    label: 'Settings Panel',
    description: 'Tune clipboard monitoring, capture types, storage limits, and appearance.',
  },
]

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

        {/* Showcase cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          {showcaseItems.map((item, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-60px" }}
              transition={{ delay: i * 0.1, duration: 0.6, ease }}
              className="group"
            >
              {/* Visual area */}
              <div className="glass-card rounded-2xl overflow-hidden mb-4 transition-all duration-500">
                <div className="aspect-[4/3] bg-void-200 relative overflow-hidden">
                  {i === 0 && <GridViewMockup />}
                  {i === 1 && <ListViewMockup />}
                  {i === 2 && <SettingsMockup />}
                  {/* Fade gradient */}
                  <div className="absolute inset-x-0 bottom-0 h-12 bg-gradient-to-t from-void-200 to-transparent pointer-events-none" />
                </div>
              </div>
              <h3 className="font-body text-base font-semibold text-ash-50 mb-1">{item.label}</h3>
              <p className="font-body text-sm text-ash-500">{item.description}</p>
            </motion.div>
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

/* --- Mockup sub-components --- */

const GridViewMockup = () => (
  <div className="p-4">
    {/* Mini tab bar */}
    <div className="flex gap-1 mb-3">
      {['All', 'Images', 'Text'].map((t, i) => (
        <div key={t} className={`px-2.5 py-1 rounded text-[9px] font-body font-medium ${i === 0 ? 'bg-violet text-white' : 'text-ash-600'}`}>
          {t}
        </div>
      ))}
    </div>
    {/* Grid */}
    <div className="grid grid-cols-2 gap-2">
      {[
        { color: '#3B82F6', type: 'img' },
        { color: '#22C55E', type: 'txt' },
        { color: '#F59E0B', type: 'file' },
        { color: '#8B5CF6', type: 'code' },
        { color: '#EC4899', type: 'img' },
        { color: '#06B6D4', type: 'txt' },
      ].map((item, i) => (
        <div key={i} className="rounded-lg bg-void-400 border border-void-500/30 overflow-hidden">
          <div className="h-12" style={{ background: `linear-gradient(135deg, ${item.color}10, ${item.color}05)` }}>
            {item.type === 'img' && (
              <div className="w-full h-full flex items-center justify-center">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={item.color} strokeWidth="1.5" opacity="0.5">
                  <rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/>
                </svg>
              </div>
            )}
            {item.type === 'txt' && (
              <div className="p-2 flex flex-col gap-0.5">
                <div className="h-1 w-[70%] rounded-full bg-ash-600/20"/>
                <div className="h-1 w-[50%] rounded-full bg-ash-600/15"/>
                <div className="h-1 w-[60%] rounded-full bg-ash-600/10"/>
              </div>
            )}
            {item.type === 'file' && (
              <div className="w-full h-full flex items-center justify-center">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={item.color} strokeWidth="1.5" opacity="0.5">
                  <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/>
                </svg>
              </div>
            )}
            {item.type === 'code' && (
              <div className="p-2 font-mono text-[6px] text-violet-300/30 leading-relaxed">
                {'{ "key": "val" }'}
              </div>
            )}
          </div>
          <div className="px-2 py-1.5 border-t border-void-500/20">
            <div className="h-1 w-[60%] rounded-full bg-ash-600/20 mb-0.5"/>
            <div className="h-1 w-[30%] rounded-full bg-ash-600/10"/>
          </div>
        </div>
      ))}
    </div>
  </div>
)

const ListViewMockup = () => (
  <div className="p-4">
    <div className="flex gap-1 mb-3">
      {['All', 'Files', 'Text'].map((t, i) => (
        <div key={t} className={`px-2.5 py-1 rounded text-[9px] font-body font-medium ${i === 0 ? 'bg-violet text-white' : 'text-ash-600'}`}>
          {t}
        </div>
      ))}
    </div>
    <div className="space-y-1.5">
      {[
        { name: 'screenshot.png', size: '2.4 MB', color: '#3B82F6', pinned: true },
        { name: 'meeting-notes.txt', size: '1.2 KB', color: '#22C55E', pinned: false },
        { name: 'design-mockup.fig', size: '48 MB', color: '#F59E0B', pinned: false },
        { name: 'api-response.json', size: '3.8 KB', color: '#8B5CF6', pinned: true },
        { name: 'photo-DSC001.jpg', size: '5.1 MB', color: '#EC4899', pinned: false },
        { name: 'presentation.key', size: '12 MB', color: '#06B6D4', pinned: false },
        { name: 'error-log.txt', size: '892 B', color: '#F87171', pinned: false },
      ].map((item, i) => (
        <div key={i} className="flex items-center gap-2.5 bg-void-400 border border-void-500/30 rounded-lg px-3 py-2">
          {item.pinned && <div className="w-0.5 h-4 rounded-full bg-violet absolute -ml-1.5" />}
          <div className="w-5 h-5 rounded flex items-center justify-center flex-shrink-0" style={{ background: `${item.color}15` }}>
            <div className="w-2 h-2 rounded-sm" style={{ background: item.color, opacity: 0.6 }} />
          </div>
          <span className="text-[10px] font-body text-ash-200 truncate flex-1">{item.name}</span>
          <span className="text-[9px] font-mono text-ash-600 flex-shrink-0">{item.size}</span>
        </div>
      ))}
    </div>
  </div>
)

const SettingsMockup = () => (
  <div className="p-4">
    <div className="text-[10px] font-body font-semibold text-ash-300 mb-3">Settings</div>
    <div className="space-y-2.5">
      {[
        { label: 'Clipboard Monitoring', type: 'toggle', on: true },
        { label: 'Capture Images', type: 'toggle', on: true },
        { label: 'Capture Text', type: 'toggle', on: true },
        { label: 'Capture Files', type: 'toggle', on: false },
        { label: 'Ignore Duplicates', type: 'toggle', on: true },
        { label: 'Polling Interval', type: 'slider', value: '0.5s' },
        { label: 'Max Items', type: 'slider', value: '200' },
        { label: 'Thumbnail Style', type: 'select', value: 'Cover' },
      ].map((setting, i) => (
        <div key={i} className="flex items-center justify-between bg-void-400 border border-void-500/30 rounded-lg px-3 py-2">
          <span className="text-[9px] font-body text-ash-300">{setting.label}</span>
          {setting.type === 'toggle' && (
            <div className={`w-6 h-3.5 rounded-full flex items-center px-0.5 ${setting.on ? 'bg-violet justify-end' : 'bg-void-600 justify-start'}`}>
              <div className="w-2.5 h-2.5 rounded-full bg-white" />
            </div>
          )}
          {setting.type === 'slider' && (
            <span className="text-[9px] font-mono text-violet">{setting.value}</span>
          )}
          {setting.type === 'select' && (
            <span className="text-[9px] font-mono text-violet">{setting.value}</span>
          )}
        </div>
      ))}
    </div>
  </div>
)

export default Showcase
