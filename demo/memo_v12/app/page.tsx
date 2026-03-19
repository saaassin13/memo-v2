import { MobileLayout } from "@/components/mobile-layout"
import { AppsGrid } from "@/components/apps-grid"
import { Search, Settings } from "lucide-react"
import Link from "next/link"

export default function HomePage() {
  return (
    <MobileLayout>
      <div className="flex flex-col">
        <header className="sticky top-0 z-40 flex items-center justify-between border-b border-border bg-card/95 px-4 py-3 backdrop-blur-md">
          <h1 className="text-xl font-semibold text-foreground">应用</h1>
          <div className="flex items-center gap-3">
            <button className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground">
              <Search className="h-5 w-5" />
            </button>
            <Link
              href="/settings"
              className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
            >
              <Settings className="h-5 w-5" />
            </Link>
          </div>
        </header>
        <div className="p-4">
          <AppsGrid />
        </div>
      </div>
    </MobileLayout>
  )
}
