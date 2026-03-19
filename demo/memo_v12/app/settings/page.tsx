"use client"

import Link from "next/link"
import { ArrowLeft, Bell, Moon, Sun, Globe, Shield, ChevronRight } from "lucide-react"
import { Switch } from "@/components/ui/switch"

const settingsGroups = [
  {
    title: "通知",
    items: [
      {
        icon: Bell,
        label: "推送通知",
        type: "switch" as const,
        defaultValue: true,
      },
    ],
  },
  {
    title: "外观",
    items: [
      {
        icon: Moon,
        label: "深色模式",
        type: "switch" as const,
        defaultValue: false,
      },
      {
        icon: Sun,
        label: "跟随系统",
        type: "switch" as const,
        defaultValue: true,
      },
    ],
  },
  {
    title: "通用",
    items: [
      {
        icon: Globe,
        label: "语言",
        type: "link" as const,
        value: "简体中文",
      },
      {
        icon: Shield,
        label: "隐私设置",
        type: "link" as const,
      },
    ],
  },
]

export default function SettingsPage() {
  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="sticky top-0 z-40 flex items-center gap-3 border-b border-border bg-card/95 px-4 py-3 backdrop-blur-md">
        <Link
          href="/profile"
          className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <h1 className="text-xl font-semibold text-foreground">设置</h1>
      </header>

      <div className="flex-1 p-4">
        {settingsGroups.map((group) => (
          <div key={group.title} className="mb-4">
            <h3 className="mb-2 px-4 text-sm font-medium text-muted-foreground">
              {group.title}
            </h3>
            <div className="rounded-2xl bg-card shadow-sm">
              {group.items.map((item, index) => {
                const Icon = item.icon
                return (
                  <div
                    key={item.label}
                    className={`flex items-center gap-3 px-4 py-3 ${
                      index < group.items.length - 1
                        ? "border-b border-border"
                        : ""
                    }`}
                  >
                    <Icon className="h-5 w-5 text-muted-foreground" />
                    <span className="flex-1 text-foreground">{item.label}</span>
                    {item.type === "switch" ? (
                      <Switch defaultChecked={item.defaultValue} />
                    ) : (
                      <div className="flex items-center gap-1 text-muted-foreground">
                        {item.value && (
                          <span className="text-sm">{item.value}</span>
                        )}
                        <ChevronRight className="h-4 w-4" />
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
