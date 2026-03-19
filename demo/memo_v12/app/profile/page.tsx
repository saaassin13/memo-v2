"use client"

import { MobileLayout } from "@/components/mobile-layout"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import {
  Download,
  Trash2,
  Palette,
  Info,
  MessageSquare,
  ChevronRight,
  Settings,
  Edit,
} from "lucide-react"
import Link from "next/link"

const stats = [
  { label: "备忘录", value: 24 },
  { label: "待办事项", value: 12 },
  { label: "连续记录", value: "7天" },
]

const menuItems = [
  {
    icon: Download,
    label: "数据导出",
    href: "#",
  },
  {
    icon: Trash2,
    label: "清除缓存",
    href: "#",
  },
  {
    icon: Palette,
    label: "主题设置",
    href: "#",
  },
  {
    icon: Settings,
    label: "通用设置",
    href: "/settings",
  },
]

const aboutItems = [
  {
    icon: Info,
    label: "版本信息",
    value: "v1.0.0",
  },
  {
    icon: MessageSquare,
    label: "意见反馈",
    href: "#",
  },
]

export default function ProfilePage() {
  return (
    <MobileLayout>
      <div className="flex flex-col">
        <header className="sticky top-0 z-40 flex items-center justify-between border-b border-border bg-card/95 px-4 py-3 backdrop-blur-md">
          <h1 className="text-xl font-semibold text-foreground">我的</h1>
          <Link
            href="/settings"
            className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
          >
            <Settings className="h-5 w-5" />
          </Link>
        </header>

        <div className="p-4">
          <div className="mb-6 flex items-center gap-4 rounded-2xl bg-card p-4 shadow-sm">
            <Avatar className="h-16 w-16">
              <AvatarImage src="/avatar.png" alt="用户头像" />
              <AvatarFallback className="bg-primary/10 text-lg text-primary">
                用户
              </AvatarFallback>
            </Avatar>
            <div className="flex-1">
              <h2 className="text-lg font-semibold text-foreground">用户名</h2>
              <p className="text-sm text-muted-foreground">
                点击编辑个人信息
              </p>
            </div>
            <button className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground">
              <Edit className="h-5 w-5" />
            </button>
          </div>

          <div className="mb-6 grid grid-cols-3 gap-3">
            {stats.map((stat) => (
              <div
                key={stat.label}
                className="flex flex-col items-center rounded-xl bg-card p-4 shadow-sm"
              >
                <span className="text-2xl font-bold text-primary">
                  {stat.value}
                </span>
                <span className="mt-1 text-xs text-muted-foreground">
                  {stat.label}
                </span>
              </div>
            ))}
          </div>

          <div className="mb-4 rounded-2xl bg-card shadow-sm">
            <h3 className="border-b border-border px-4 py-3 text-sm font-medium text-muted-foreground">
              功能
            </h3>
            {menuItems.map((item, index) => {
              const Icon = item.icon
              return (
                <Link
                  key={item.label}
                  href={item.href}
                  className={`flex items-center gap-3 px-4 py-3 transition-colors hover:bg-secondary/50 ${
                    index < menuItems.length - 1 ? "border-b border-border" : ""
                  }`}
                >
                  <Icon className="h-5 w-5 text-muted-foreground" />
                  <span className="flex-1 text-foreground">{item.label}</span>
                  <ChevronRight className="h-4 w-4 text-muted-foreground" />
                </Link>
              )
            })}
          </div>

          <div className="rounded-2xl bg-card shadow-sm">
            <h3 className="border-b border-border px-4 py-3 text-sm font-medium text-muted-foreground">
              关于
            </h3>
            {aboutItems.map((item, index) => {
              const Icon = item.icon
              const isLink = "href" in item
              const content = (
                <>
                  <Icon className="h-5 w-5 text-muted-foreground" />
                  <span className="flex-1 text-foreground">{item.label}</span>
                  {"value" in item ? (
                    <span className="text-sm text-muted-foreground">
                      {item.value}
                    </span>
                  ) : (
                    <ChevronRight className="h-4 w-4 text-muted-foreground" />
                  )}
                </>
              )
              const className = `flex items-center gap-3 px-4 py-3 transition-colors hover:bg-secondary/50 ${
                index < aboutItems.length - 1 ? "border-b border-border" : ""
              }`

              return isLink ? (
                <Link key={item.label} href={item.href} className={className}>
                  {content}
                </Link>
              ) : (
                <div key={item.label} className={className}>
                  {content}
                </div>
              )
            })}
          </div>
        </div>
      </div>
    </MobileLayout>
  )
}
