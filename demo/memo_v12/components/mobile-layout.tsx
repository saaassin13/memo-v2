"use client"

import { usePathname } from "next/navigation"
import Link from "next/link"
import { cn } from "@/lib/utils"
import { LayoutGrid, CheckSquare, Calendar, User } from "lucide-react"

const navItems = [
  { href: "/", label: "应用", icon: LayoutGrid },
  { href: "/todo", label: "Todo", icon: CheckSquare },
  { href: "/calendar", label: "日历", icon: Calendar },
  { href: "/profile", label: "我的", icon: User },
]

interface MobileLayoutProps {
  children: React.ReactNode
}

export function MobileLayout({ children }: MobileLayoutProps) {
  const pathname = usePathname()

  const isActive = (href: string) => {
    if (href === "/") {
      return pathname === "/" || pathname.startsWith("/apps")
    }
    return pathname.startsWith(href)
  }

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <main className="flex-1 pb-20">{children}</main>
      <nav className="fixed bottom-0 left-0 right-0 z-50 border-t border-border bg-card/95 backdrop-blur-md">
        <div className="mx-auto flex max-w-md items-center justify-around px-4 py-2">
          {navItems.map((item) => {
            const Icon = item.icon
            const active = isActive(item.href)
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex flex-col items-center gap-1 rounded-lg px-4 py-2 transition-colors",
                  active
                    ? "text-primary"
                    : "text-muted-foreground hover:text-foreground"
                )}
              >
                <Icon className={cn("h-5 w-5", active && "stroke-[2.5px]")} />
                <span className="text-xs font-medium">{item.label}</span>
              </Link>
            )
          })}
        </div>
        <div className="h-[env(safe-area-inset-bottom)]" />
      </nav>
    </div>
  )
}
