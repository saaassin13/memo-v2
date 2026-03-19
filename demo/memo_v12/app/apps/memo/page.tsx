"use client"

import { useState } from "react"
import Link from "next/link"
import { ArrowLeft, Search, Plus, Pin, MoreHorizontal, Trash2, Edit, Settings2, List, Grid3X3, Clock, CalendarDays, Check } from "lucide-react"
import { cn } from "@/lib/utils"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Drawer,
  DrawerContent,
  DrawerDescription,
  DrawerHeader,
  DrawerTitle,
} from "@/components/ui/drawer"

const categories = ["全部", "工作", "生活", "学习"]

interface Memo {
  id: string
  title: string
  content: string
  category: string
  createdAt: string
  updatedAt: string
  pinned: boolean
}

type ViewMode = "list" | "grid"
type SortMode = "createdAt" | "updatedAt"

const initialMemos: Memo[] = [
  {
    id: "1",
    title: "项目会议记录",
    content: "讨论了新功能的开发计划 确定了下周的里程碑目标",
    category: "工作",
    createdAt: "2026-03-15",
    updatedAt: "2026-03-18",
    pinned: true,
  },
  {
    id: "2",
    title: "购物清单",
    content: "牛奶 面包 鸡蛋 蔬菜 水果",
    category: "生活",
    createdAt: "2026-03-16",
    updatedAt: "2026-03-17",
    pinned: false,
  },
  {
    id: "3",
    title: "学习笔记",
    content: "React 18 features",
    category: "学习",
    createdAt: "2026-03-14",
    updatedAt: "2026-03-16",
    pinned: false,
  },
  {
    id: "4",
    title: "健身计划",
    content: "周一胸部 周三背部 周五腿部",
    category: "生活",
    createdAt: "2026-03-10",
    updatedAt: "2026-03-15",
    pinned: true,
  },
]

export default function MemoListPage() {
  const [activeCategory, setActiveCategory] = useState("全部")
  const [memos, setMemos] = useState<Memo[]>(initialMemos)
  const [settingsOpen, setSettingsOpen] = useState(false)
  const [viewMode, setViewMode] = useState<ViewMode>("list")
  const [sortMode, setSortMode] = useState<SortMode>("updatedAt")

  const filteredMemos =
    activeCategory === "全部"
      ? memos
      : memos.filter((memo) => memo.category === activeCategory)

  const sortedMemos = [...filteredMemos].sort((a, b) => {
    const dateA = new Date(sortMode === "createdAt" ? a.createdAt : a.updatedAt)
    const dateB = new Date(sortMode === "createdAt" ? b.createdAt : b.updatedAt)
    return dateB.getTime() - dateA.getTime()
  })

  const pinnedMemos = sortedMemos.filter((m) => m.pinned)
  const otherMemos = sortedMemos.filter((m) => !m.pinned)

  const deleteMemo = (id: string) => {
    setMemos((prev) => prev.filter((m) => m.id !== id))
  }

  const togglePin = (id: string) => {
    setMemos((prev) =>
      prev.map((m) => (m.id === id ? { ...m, pinned: !m.pinned } : m))
    )
  }

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="sticky top-0 z-40 border-b border-border bg-card/95 backdrop-blur-md">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center gap-3">
            <Link
              href="/"
              className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
            >
              <ArrowLeft className="h-5 w-5" />
            </Link>
            <h1 className="text-xl font-semibold text-foreground">备忘录</h1>
          </div>
          <div className="flex items-center gap-1">
            <button className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground">
              <Search className="h-5 w-5" />
            </button>
            <button
              onClick={() => setSettingsOpen(true)}
              className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground"
            >
              <Settings2 className="h-5 w-5" />
            </button>
          </div>
        </div>
        <div className="flex gap-2 overflow-x-auto px-4 pb-3 scrollbar-hide">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setActiveCategory(cat)}
              className={cn(
                "shrink-0 rounded-full px-4 py-1.5 text-sm font-medium transition-colors",
                activeCategory === cat
                  ? "bg-primary text-primary-foreground"
                  : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
              )}
            >
              {cat}
            </button>
          ))}
        </div>
      </header>

      <div className="flex-1 p-4">
        {pinnedMemos.length > 0 && (
          <div className="mb-6">
            <h2 className="mb-3 flex items-center gap-2 text-sm font-medium text-muted-foreground">
              <Pin className="h-4 w-4" />
              置顶
            </h2>
            <div className={cn(
              viewMode === "grid" 
                ? "grid grid-cols-2 gap-3" 
                : "space-y-3"
            )}>
              {pinnedMemos.map((memo) => (
                <MemoCard
                  key={memo.id}
                  memo={memo}
                  viewMode={viewMode}
                  onDelete={deleteMemo}
                  onTogglePin={togglePin}
                />
              ))}
            </div>
          </div>
        )}
        {otherMemos.length > 0 && (
          <div>
            {pinnedMemos.length > 0 && (
              <h2 className="mb-3 text-sm font-medium text-muted-foreground">
                其他
              </h2>
            )}
            <div className={cn(
              viewMode === "grid" 
                ? "grid grid-cols-2 gap-3" 
                : "space-y-3"
            )}>
              {otherMemos.map((memo) => (
                <MemoCard
                  key={memo.id}
                  memo={memo}
                  viewMode={viewMode}
                  onDelete={deleteMemo}
                  onTogglePin={togglePin}
                />
              ))}
            </div>
          </div>
        )}
      </div>

      <Link
        href="/apps/memo/new"
        className="fixed bottom-6 right-4 z-40 flex h-14 w-14 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-transform hover:scale-105 active:scale-95"
      >
        <Plus className="h-6 w-6" />
      </Link>

      <Drawer open={settingsOpen} onOpenChange={setSettingsOpen}>
        <DrawerContent>
          <DrawerHeader>
            <DrawerTitle>显示设置</DrawerTitle>
            <DrawerDescription>选择备忘录的展示样式和排序方式</DrawerDescription>
          </DrawerHeader>
          <div className="px-4 pb-8 space-y-6">
            <div>
              <h3 className="text-sm font-medium text-foreground mb-3">展示样式</h3>
              <div className="flex gap-3">
                <button
                  onClick={() => setViewMode("list")}
                  className={cn(
                    "flex flex-1 flex-col items-center gap-2 rounded-xl border-2 p-4 transition-colors",
                    viewMode === "list"
                      ? "border-primary bg-primary/5"
                      : "border-border hover:border-primary/50"
                  )}
                >
                  <List className={cn("h-6 w-6", viewMode === "list" ? "text-primary" : "text-muted-foreground")} />
                  <span className={cn("text-sm font-medium", viewMode === "list" ? "text-primary" : "text-foreground")}>列表</span>
                  {viewMode === "list" && <Check className="h-4 w-4 text-primary" />}
                </button>
                <button
                  onClick={() => setViewMode("grid")}
                  className={cn(
                    "flex flex-1 flex-col items-center gap-2 rounded-xl border-2 p-4 transition-colors",
                    viewMode === "grid"
                      ? "border-primary bg-primary/5"
                      : "border-border hover:border-primary/50"
                  )}
                >
                  <Grid3X3 className={cn("h-6 w-6", viewMode === "grid" ? "text-primary" : "text-muted-foreground")} />
                  <span className={cn("text-sm font-medium", viewMode === "grid" ? "text-primary" : "text-foreground")}>九宫格</span>
                  {viewMode === "grid" && <Check className="h-4 w-4 text-primary" />}
                </button>
              </div>
            </div>
            <div>
              <h3 className="text-sm font-medium text-foreground mb-3">排序方式</h3>
              <div className="flex gap-3">
                <button
                  onClick={() => setSortMode("createdAt")}
                  className={cn(
                    "flex flex-1 flex-col items-center gap-2 rounded-xl border-2 p-4 transition-colors",
                    sortMode === "createdAt"
                      ? "border-primary bg-primary/5"
                      : "border-border hover:border-primary/50"
                  )}
                >
                  <CalendarDays className={cn("h-6 w-6", sortMode === "createdAt" ? "text-primary" : "text-muted-foreground")} />
                  <span className={cn("text-sm font-medium", sortMode === "createdAt" ? "text-primary" : "text-foreground")}>创建时间</span>
                  {sortMode === "createdAt" && <Check className="h-4 w-4 text-primary" />}
                </button>
                <button
                  onClick={() => setSortMode("updatedAt")}
                  className={cn(
                    "flex flex-1 flex-col items-center gap-2 rounded-xl border-2 p-4 transition-colors",
                    sortMode === "updatedAt"
                      ? "border-primary bg-primary/5"
                      : "border-border hover:border-primary/50"
                  )}
                >
                  <Clock className={cn("h-6 w-6", sortMode === "updatedAt" ? "text-primary" : "text-muted-foreground")} />
                  <span className={cn("text-sm font-medium", sortMode === "updatedAt" ? "text-primary" : "text-foreground")}>修改时间</span>
                  {sortMode === "updatedAt" && <Check className="h-4 w-4 text-primary" />}
                </button>
              </div>
            </div>
          </div>
        </DrawerContent>
      </Drawer>
    </div>
  )
}

function MemoCard({
  memo,
  viewMode,
  onDelete,
  onTogglePin,
}: {
  memo: Memo
  viewMode: ViewMode
  onDelete: (id: string) => void
  onTogglePin: (id: string) => void
}) {
  const categoryColors: Record<string, string> = {
    工作: "bg-chart-1/10 text-chart-1",
    生活: "bg-accent/10 text-accent",
    学习: "bg-chart-3/10 text-chart-3",
  }

  if (viewMode === "grid") {
    return (
      <Link
        href={`/apps/memo/${memo.id}`}
        className="block rounded-xl bg-card p-3 shadow-sm transition-all hover:shadow-md active:scale-[0.98] aspect-square"
      >
        <div className="flex flex-col h-full">
          <div className="flex items-start justify-between mb-2">
            <span
              className={cn(
                "rounded-full px-2 py-0.5 text-xs font-medium",
                categoryColors[memo.category] || "bg-muted text-muted-foreground"
              )}
            >
              {memo.category}
            </span>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <button
                  onClick={(e) => e.preventDefault()}
                  className="rounded-full p-1 text-muted-foreground hover:bg-secondary hover:text-foreground -mr-1 -mt-1"
                >
                  <MoreHorizontal className="h-3 w-3" />
                </button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem
                  onClick={(e) => {
                    e.preventDefault()
                    onTogglePin(memo.id)
                  }}
                >
                  <Pin className="mr-2 h-4 w-4" />
                  {memo.pinned ? "取消置顶" : "置顶"}
                </DropdownMenuItem>
                <DropdownMenuItem>
                  <Edit className="mr-2 h-4 w-4" />
                  编辑
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={(e) => {
                    e.preventDefault()
                    onDelete(memo.id)
                  }}
                  className="text-destructive focus:text-destructive"
                >
                  <Trash2 className="mr-2 h-4 w-4" />
                  删除
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
          <h3 className="font-medium text-foreground text-sm line-clamp-2">{memo.title}</h3>
          <p className="mt-1 flex-1 line-clamp-3 text-xs text-muted-foreground">
            {memo.content}
          </p>
          <span className="text-xs text-muted-foreground mt-2">{memo.updatedAt}</span>
        </div>
      </Link>
    )
  }

  return (
    <Link
      href={`/apps/memo/${memo.id}`}
      className="block rounded-xl bg-card p-4 shadow-sm transition-all hover:shadow-md active:scale-[0.98]"
    >
      <div className="flex items-start justify-between">
        <div className="flex-1 min-w-0">
          <h3 className="font-medium text-foreground">{memo.title}</h3>
          <p className="mt-1 line-clamp-2 text-sm text-muted-foreground">
            {memo.content}
          </p>
          <div className="mt-2 flex items-center gap-2">
            <span
              className={cn(
                "rounded-full px-2 py-0.5 text-xs font-medium",
                categoryColors[memo.category] || "bg-muted text-muted-foreground"
              )}
            >
              {memo.category}
            </span>
            <span className="text-xs text-muted-foreground">{memo.updatedAt}</span>
          </div>
        </div>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button
              onClick={(e) => e.preventDefault()}
              className="rounded-full p-1 text-muted-foreground hover:bg-secondary hover:text-foreground"
            >
              <MoreHorizontal className="h-4 w-4" />
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem
              onClick={(e) => {
                e.preventDefault()
                onTogglePin(memo.id)
              }}
            >
              <Pin className="mr-2 h-4 w-4" />
              {memo.pinned ? "取消置顶" : "置顶"}
            </DropdownMenuItem>
            <DropdownMenuItem>
              <Edit className="mr-2 h-4 w-4" />
              编辑
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={(e) => {
                e.preventDefault()
                onDelete(memo.id)
              }}
              className="text-destructive focus:text-destructive"
            >
              <Trash2 className="mr-2 h-4 w-4" />
              删除
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </Link>
  )
}
