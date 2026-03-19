"use client"

import Link from "next/link"
import { cn } from "@/lib/utils"
import {
  FileText,
  CalendarHeart,
  BookOpen,
  Wallet,
  Target,
  Scale,
} from "lucide-react"

const apps = [
  {
    id: "memo",
    name: "备忘录",
    icon: FileText,
    href: "/apps/memo",
    color: "bg-primary/10 text-primary",
  },
  {
    id: "countdown",
    name: "倒数纪念日",
    icon: CalendarHeart,
    href: "/apps/countdown",
    color: "bg-chart-4/10 text-chart-4",
  },
  {
    id: "diary",
    name: "日记",
    icon: BookOpen,
    href: "/apps/diary",
    color: "bg-accent/10 text-accent",
  },
  {
    id: "accounting",
    name: "记账",
    icon: Wallet,
    href: "/apps/accounting",
    color: "bg-chart-3/10 text-chart-3",
  },
  {
    id: "goals",
    name: "目标",
    icon: Target,
    href: "/apps/goals",
    color: "bg-chart-1/10 text-chart-1",
  },
  {
    id: "weight",
    name: "体重",
    icon: Scale,
    href: "/apps/weight",
    color: "bg-chart-5/10 text-chart-5",
  },
]

export function AppsGrid() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {apps.map((app) => {
        const Icon = app.icon
        return (
          <Link
            key={app.id}
            href={app.href}
            className="group flex flex-col items-center gap-2 rounded-2xl bg-card p-4 shadow-sm transition-all hover:shadow-md active:scale-95"
          >
            <div
              className={cn(
                "flex h-14 w-14 items-center justify-center rounded-2xl transition-transform group-hover:scale-105",
                app.color
              )}
            >
              <Icon className="h-7 w-7" />
            </div>
            <span className="text-sm font-medium text-foreground">
              {app.name}
            </span>
          </Link>
        )
      })}
    </div>
  )
}
