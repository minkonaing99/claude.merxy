import { Bar, Collapse, Stage, States, Text, Window, type Act } from '../../kit'
import { BadgeCheck, Banknote, Boxes, ClipboardList, Inbox, Milk, PackageCheck, PhoneCall, ShieldAlert, ShoppingBag, Truck, Undo2, Users } from 'lucide-react'
import './nm.css'

// Natural Mountain staff admin: from the day's work queue to a business customer,
// in the brand's own greens and the words staff use on the phone.

type Page = 'today' | 'customers' | 'detail'
type S = { page: Page; business: boolean }

const initial: S = { page: 'today', business: false }
const POSTER: S = { page: 'customers', business: true }

const NAV = [
  { id: 'today', label: 'Today', icon: ClipboardList },
  { id: 'orders', label: 'Orders', icon: ShoppingBag },
  { id: 'requests', label: 'Requests', icon: Inbox },
  { id: 'stock', label: 'Stock + packing', icon: Boxes },
  { id: 'deliveries', label: 'Deliveries', icon: PackageCheck },
  { id: 'dispatch', label: 'Dispatch', icon: Truck },
  { id: 'customers', label: 'Customers', icon: Users },
  { id: 'unpaid', label: 'Unpaid orders', icon: Banknote },
  { id: 'products', label: 'Products', icon: Milk },
] as const

type Customer = { name: string; type: 'business' | 'household'; city: string; waiting?: boolean }
const CUSTOMERS: Customer[] = [
  { name: 'Golden Star', type: 'business', city: 'Mandalay' },
  { name: 'May Thu', type: 'household', city: 'Yangon', waiting: true },
  { name: 'Palace Tea House', type: 'business', city: 'Yangon' },
  { name: 'Aye Aye', type: 'household', city: 'Mandalay' },
  { name: 'Mandalay Hill Cafe', type: 'business', city: 'Mandalay' },
  { name: 'Wai Wai', type: 'household', city: 'Mandalay' },
  { name: 'City Brew', type: 'business', city: 'Mandalay' },
  { name: 'Khin Khin', type: 'household', city: 'Mandalay' },
  { name: 'Green Leaf Tea', type: 'business', city: 'Mandalay' },
]

async function script(a: Act<S>) {
  await a.wait(1400)
  await a.move('nav-customers')
  await a.wait(200)
  await a.click()
  await a.set({ page: 'customers' })
  await a.wait(1100)
  await a.move({ at: 'pill-business', x: 0.75, y: 0.8 })
  await a.wait(200)
  await a.click()
  await a.set({ business: true })
  await a.wait(1400)
  await a.move('row-golden')
  await a.wait(250)
  await a.click()
  await a.set({ page: 'detail' })
  await a.wait(2800)
  // Back to the queue through the sidebar, so the loop restarts where it began
  await a.move('nav-today')
  await a.wait(200)
  await a.click()
  await a.set({ page: 'today', business: false })
  await a.wait(500)
  await a.move(a.layout === 'compact' ? { x: 280, y: 120 } : { x: 640, y: 120 })
  await a.wait(300)
}

export function NmAdmin() {
  return (
    <Stage width={900} height={440} compact={{ below: 600, width: 358, height: 440 }} initial={initial} poster={POSTER} script={script}
      cursor={{ at: { wide: { x: 640, y: 120 }, compact: { x: 280, y: 120 } } }} className="nm">
      {(s, _rect, layout) => (
        <Window url="admin.naturalmountaindairy.store" className="nm-window">
          <div className="nm-app">
            {layout === 'wide' && <Sidebar page={s.page} />}
            <main className="nm-main">
              {layout === 'compact' && (
                <div className="nm-topnav">
                  {NAV.filter((n) => ['today', 'orders', 'customers'].includes(n.id)).map(({ id, label }) => (
                    <span key={id} className="nm-nav" data-active={(s.page === 'detail' ? 'customers' : s.page) === id} data-target={`nav-${id}`} data-cursor="pointer">{label}</span>
                  ))}
                </div>
              )}
              <States value={s.page} align="start" states={{ today: <Today />, customers: <Customers business={s.business} />, detail: <Detail /> }} />
            </main>
          </div>
        </Window>
      )}
    </Stage>
  )
}

function Sidebar({ page }: { page: Page }) {
  const active = page === 'detail' ? 'customers' : page
  return (
    <aside className="nm-side">
      <div className="nm-brand">
        <span className="nm-logo" aria-hidden><Milk size={15} /></span>
        <div><div className="nm-brand-name">Natural Mountain</div><div className="nm-brand-sub">Staff admin</div></div>
      </div>
      {NAV.map(({ id, label, icon: I }) => (
        <div key={id} className="nm-nav" data-active={active === id} data-target={`nav-${id}`} data-cursor="pointer">
          <I size={14} aria-hidden />{label}
        </div>
      ))}
      <div className="nm-user"><span className="nm-avatar">MN</span><Bar w={70} h={6} tone={2} /></div>
    </aside>
  )
}

function Kpi({ label, value, icon: I, tone }: { label: string; value: string; icon: typeof Users; tone: 'amber' | 'green' | 'red' }) {
  return (
    <div className="nm-kpi">
      <div className="nm-kpi-top"><span className="nm-kpi-label">{label}</span><span className="nm-tile" data-tone={tone}><I size={13} /></span></div>
      <div className="nm-kpi-value">{value}</div>
    </div>
  )
}

function Today() {
  return (
    <div className="nm-page">
      <h1 className="nm-h1">Today</h1>
      <p className="nm-sub">Thursday 12 November · Both cities</p>
      <div className="nm-kpis">
        <Kpi label="To verify" value="1" icon={PhoneCall} tone="amber" />
        <Kpi label="Change requests" value="5" icon={Inbox} tone="amber" />
        <Kpi label="Needs review" value="0" icon={ShieldAlert} tone="green" />
        <Kpi label="Refusals" value="0" icon={Undo2} tone="green" />
        <Kpi label="Unpaid" value="81,000 Ks" icon={Banknote} tone="red" />
      </div>
      <div className="nm-card">
        <div className="nm-card-title">Customers to verify</div>
        <div className="nm-line"><span className="nm-strong">May Thu</span><span className="nm-badges"><span className="nm-badge" data-tone="grey">Household</span><span className="nm-badge" data-tone="outline">Yangon</span></span></div>
        <div className="nm-line"><Bar w={110} h={7} tone={2} /><Bar w={60} h={14} r={7} tone={1} /></div>
      </div>
    </div>
  )
}

function Customers({ business }: { business: boolean }) {
  return (
    <div className="nm-page">
      <h1 className="nm-h1">Customers</h1>
      <div className="nm-toolbar">
        <div className="nm-search"><Text filler>Search name, phone, business</Text></div>
        <div className="nm-pills" role="radiogroup">
          <span className="nm-pill" data-on={!business}>All</span>
          <span className="nm-pill" data-on={business} data-target="pill-business" data-cursor="pointer">Business</span>
          <span className="nm-pill">Household</span>
        </div>
      </div>
      <div className="nm-table">
        <div className="nm-tr nm-th"><span>Name</span><span>Type</span><span>City</span><span>Status</span></div>
        {CUSTOMERS.map((c) => (
          <Collapse key={c.name} open={!business || c.type === 'business'}>
            <div className="nm-tr" data-target={c.name === 'Golden Star' ? 'row-golden' : undefined} data-cursor="pointer">
              <span className="nm-strong">{c.name}</span>
              <span><span className="nm-badge" data-tone={c.type === 'business' ? 'green' : 'grey'}>{c.type === 'business' ? 'Business' : 'Household'}</span></span>
              <span><span className="nm-badge" data-tone="outline">{c.city}</span></span>
              <span><span className="nm-badge" data-tone={c.waiting ? 'amber' : 'green'}>{c.waiting ? 'Waiting for call' : 'Active'}</span></span>
            </div>
          </Collapse>
        ))}
      </div>
    </div>
  )
}

function Detail() {
  return (
    <div className="nm-page">
      <div className="nm-crumb">Customers</div>
      <div className="nm-head">
        <h1 className="nm-h1">Golden Star</h1>
        <span className="nm-badges"><span className="nm-badge" data-tone="green">Business</span><span className="nm-badge" data-tone="outline">Mandalay</span><span className="nm-badge" data-tone="green">Active</span></span>
      </div>
      <div className="nm-kpis nm-kpis--4">
        <Kpi label="Plans" value="2" icon={Milk} tone="green" />
        <Kpi label="Upcoming" value="10" icon={Truck} tone="green" />
        <Kpi label="Unpaid" value="81,000 Ks" icon={Banknote} tone="red" />
        <Kpi label="Verified" value="Yes" icon={BadgeCheck} tone="green" />
      </div>
      <div className="nm-card">
        <div className="nm-card-title">Upcoming deliveries</div>
        <div className="nm-line"><span><span className="nm-strong">Tomorrow</span> <span className="nm-muted">· Plan</span></span><span className="nm-badges"><span className="nm-badge" data-tone="amber">Pending</span><span className="nm-money">13,500 Ks</span></span></div>
        <div className="nm-line"><span><span className="nm-strong">Mon 16 Nov</span> <span className="nm-muted">· Plan</span></span><span className="nm-badges"><span className="nm-badge" data-tone="amber">Pending</span><span className="nm-money">32,600 Ks</span></span></div>
      </div>
    </div>
  )
}
