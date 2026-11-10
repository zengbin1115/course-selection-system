<template>
  <div class="bg-gray-100 text-on-surface min-h-screen relative">
    <canvas ref="canvasRef" class="fixed inset-0 w-full h-full z-[0] pointer-events-none"></canvas>

    <header class="fixed top-0 w-full z-50 bg-surface/90 backdrop-blur-sm flex justify-between items-center px-container-margin h-16 shadow-sm border-b border-outline-variant">
      <div class="flex items-center gap-4 relative">
        <span 
          class="material-symbols-outlined text-primary cursor-pointer hover:bg-surface-container-high p-2 rounded-full transition-colors"
          @click="isMenuOpen = !isMenuOpen"
        >menu</span>
        <h1 class="font-headline-lg text-headline-lg font-bold text-primary">東海通識課程推薦系統</h1>

        <div v-if="isMenuOpen" class="absolute top-14 left-0 mt-2 w-48 bg-surface rounded-xl shadow-lg border border-outline-variant overflow-hidden z-50">
          <Link href="/index" class="block px-4 py-3 text-on-surface hover:bg-surface-container-high hover:text-primary transition-colors no-underline">首頁</Link>
          <Link href="/cpas/enter" class="block px-4 py-3 text-on-surface hover:bg-surface-container-high hover:text-primary transition-colors no-underline">分數輸入</Link>
          <Link href="/cpas/courses" class="block px-4 py-3 text-on-surface hover:bg-surface-container-high hover:text-primary transition-colors no-underline">瀏覽所有課程</Link>
        </div>
      </div>
      <nav class="hidden md:flex items-center gap-6">
        <Link href="/index" class="text-on-surface font-label-lg px-4 py-2 hover:bg-surface-container-high rounded-lg no-underline text-primary font-bold">首頁</Link>
      </nav>
    </header>

    <div v-if="isMenuOpen" @click="isMenuOpen = false" class="fixed inset-0 z-40"></div>

    <main class="max-w-[1440px] mx-auto px-container-margin pb-xl pt-[100px] relative z-10">
      <div class="mb-xl">
        <h2 class="font-display-lg text-display-lg mb-2">Analysis Results</h2>
        <p class="text-on-surface-variant font-body-lg">根據您的核心能力分析，我們為您規劃了專屬的職能成長路徑。</p>
      </div>

      <section class="mb-2xl">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div
            v-for="(val, key) in competencyScores"
            :key="key"
            class="glass-card p-lg rounded-xl border-l-4 shadow-sm hover:shadow-lg hover:-translate-y-1 transition-all duration-300 bg-surface"
            :class="getBorderColor(key)"
          >
            <h4 class="font-headline-md mb-sm">{{ val.name }}</h4>
            <span class="text-display-lg leading-none">{{ val.score }}</span>
          </div>
        </div>
      </section>

      <section>
        <div class="flex items-center justify-between mb-lg">
          <h3 class="font-headline-lg text-headline-lg font-bold">推薦通識課程</h3>
        </div>

        <div class="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-4 mb-4">
          <span class="font-bold text-on-surface-variant whitespace-nowrap">職能篩選：</span>
          <div class="flex items-center gap-3 flex-wrap">
            <button
              v-for="opt in strengthOptions"
              :key="opt.id"
              @click="activeStrength = opt.id"
              :class="[
                'px-4 py-1.5 rounded-full border transition-colors text-sm font-medium',
                activeStrength === opt.id
                  ? 'bg-primary text-on-primary border-primary shadow-sm'
                  : 'border-outline-variant text-on-surface hover:bg-primary/5'
              ]"
            >{{ opt.label }}</button>
          </div>
        </div>

        <div class="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-4 mb-lg">
          <span class="font-bold text-on-surface-variant whitespace-nowrap">領域篩選：</span>
          <div class="flex items-center gap-3 flex-wrap">
            <button
              v-for="tab in filterTabs"
              :key="tab.id"
              @click="activeDepartment = tab.id"
              :class="[
                'px-4 py-1.5 rounded-full border transition-colors text-sm font-medium',
                activeDepartment === tab.id
                  ? 'bg-primary text-on-primary border-primary shadow-sm'
                  : 'border-outline-variant text-on-surface hover:bg-primary/5'
              ]"
            >{{ tab.label }}</button>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-lg">
          <div
            v-for="course in filteredCourses"
            :key="course.class_id"
            class="flex flex-col bg-surface border border-outline-variant rounded-xl overflow-hidden hover:shadow-lg transition-all p-lg"
          >
            <div class="flex flex-col gap-1 mb-2">
              <div class="flex flex-wrap gap-2 mb-2 items-center">
                <span class="text-[11px] bg-secondary/10 text-black px-2 py-0.5 rounded-md font-medium">
                  {{ course.department }}
                </span>
                <span class="text-[11px] bg-outline-variant/30 text-black px-2 py-0.5 rounded-md font-medium">
                  {{ course.credits }} 學分
                </span>
                
                <!--強弱關係視覺標籤 -->
                <span 
                  v-if="course.relation_type === 'strong' || course.relation_type === 'both'" 
                  class="text-[11px] bg-blue-100 text-blue-800 border border-blue-200 px-2 py-0.5 rounded-md font-bold tracking-wide"
                >
                  強關係推薦
                </span>
                <span 
                  v-if="course.relation_type === 'weak' || course.relation_type === 'both'" 
                  class="text-[11px] bg-orange-100 text-orange-800 border border-orange-200 px-2 py-0.5 rounded-md font-bold tracking-wide"
                >
                  弱關係推薦
                </span>
              </div>
              <span class="font-headline-md">{{ course.class_name }}</span>
              <span v-if="course.class_name_en" class="text-sm text-black truncate">{{ course.class_name_en }}</span>
            </div>

            <div class="flex flex-col gap-1 text-black mb-md mt-2">
              <div v-if="course.teacher" class="flex items-center gap-sm">
                <span class="material-symbols-outlined text-[18px]">person</span>
                授課教師: {{ course.teacher }}
              </div>
              <div v-if="course.class_time" class="flex items-center gap-sm">
                <span class="material-symbols-outlined text-[18px]">schedule</span>
                時間教室: {{ course.class_time }}
              </div>
            </div>

            <div v-if="course.outline" class="text-body-sm text-gray-700 bg-surface-container-low p-md rounded-lg max-h-50 overflow-y-auto mb-md [&::-webkit-scrollbar]:w-1.5 [&::-webkit-scrollbar-track]:bg-gray-200 [&::-webkit-scrollbar-thumb]:bg-gray-400 [&::-webkit-scrollbar-thumb]:rounded-full" :title="course.outline">
              <strong>大綱摘要：</strong>{{ course.outline }}
            </div>

            <div class="mt-auto pt-md border-t border-outline-variant flex items-center justify-between">
              <p class="text-on-surface-variant font-body-md">
                <strong>適配度：</strong><span class="text-primary font-bold text-lg">{{ course.match_score }}%</span>
              </p>
              
              <a 
                v-if="course.course_url" 
                :href="course.course_url" 
                target="_blank" 
                class="text-sm text-primary flex items-center gap-0.5 hover:underline font-medium"
              >
                課程詳情 <span class="material-symbols-outlined text-sm">open_in_new</span>
              </a>
            </div>
          </div>
        </div>

        <div v-if="filteredCourses.length === 0" class="text-center py-xl text-on-surface-variant border-2 border-dashed border-outline-variant rounded-xl mt-4">
          目前沒有符合此篩選條件的推薦課程
        </div>
      </section>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
import { Link } from '@inertiajs/vue3';

// 🌟 1. 定義完整的 Recommendation 介面 (加入 relation_type)
interface Recommendation {
  class_id:      string;
  class_name:    string;
  class_name_en: string;
  department:    string;
  teacher:       string;
  credits:       string;
  class_time:    string;
  outline:       string;
  course_url:    string;
  match_score:   number;
  relation_type?: string; // 👈 接收後端傳來的強弱關係 (strong, weak, both)
}

const props = defineProps<{
  userScores:      number[];           
  recommendations: Recommendation[];
}>();

// 選單控制
const isMenuOpen = ref(false);

// 🌟 2. 能力分數卡片映射
const competencyScores = computed(() => ({
  execution:    { name: '執行力', score: props.userScores[0] ?? 0 },
  leadership:   { name: '統御力', score: props.userScores[1] ?? 0 },
  affability:   { name: '親和力', score: props.userScores[2] ?? 0 },
  innovation:   { name: '開創力', score: props.userScores[3] ?? 0 },
  adaptability: { name: '應變力', score: props.userScores[4] ?? 0 },
  sensitivity:  { name: '敏感力', score: props.userScores[5] ?? 0 },
}));

const getBorderColor = (key: string) => {
  const colors: Record<string, string> = {
    execution:    'border-primary',
    leadership:   'border-secondary',
    affability:   'border-green-500',
    innovation:   'border-amber-500',
    adaptability: 'border-blue-500',
    sensitivity:  'border-red-500',
  };
  return colors[key] || 'border-gray-300';
};

// 🌟 3. 強弱項篩選器選項 (大幅簡化，不需再用 computed 算分數)
const activeStrength = ref<string>('');
const strengthOptions = [
  { id: '', label: '全部顯示' },
  { id: 'strong', label: '強關係推薦' },
  { id: 'weak', label: '弱關係推薦' }
];

// 🌟 4. 領域篩選器
const activeDepartment = ref<string>('');
const filterTabs = computed(() => {
  const tabs = [{ id: '', label: '全部領域' }];
  const uniqueDeps = new Set(props.recommendations.map(c => c.department));
  uniqueDeps.forEach(dep => {
    if (dep && dep !== '未知系所') tabs.push({ id: dep, label: dep });
  });
  return tabs;
});

// 🌟 5. 雙重過濾邏輯 (直接用 relation_type 判斷)
const filteredCourses = computed(() => {
  let result = props.recommendations;

  // 過濾強弱關係 (如果課程是 both，則點選強或弱都會顯示)
  if (activeStrength.value === 'strong') {
    result = result.filter(c => c.relation_type === 'strong' || c.relation_type === 'both');
  } else if (activeStrength.value === 'weak') {
    result = result.filter(c => c.relation_type === 'weak' || c.relation_type === 'both');
  }

  // 過濾領域
  if (activeDepartment.value) {
    result = result.filter(c => c.department === activeDepartment.value);
  }

  return result;
});

// ==========================================
// 🌟 背景粒子邏輯
// ==========================================
const canvasRef = ref<HTMLCanvasElement | null>(null);
let animationFrameId: number;

onMounted (() => {
  const canvas = canvasRef.value;
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  let width = window.innerWidth;
  let height = window.innerHeight;
  canvas.width = width;
  canvas.height = height;

  const particles: any[] = [];
  const particleCount = 70;
  const mouse = { x: -1000, y: -1000 };

  for (let i = 0; i < particleCount; i++) {
    particles.push({
      x: Math.random() * width,
      y: Math.random() * height,
      vx: (Math.random() - 0.5) * 1.5,
      vy: (Math.random() - 0.5) * 1.5,
      radius: Math.random() * 2 + 1
    });
  }

  const handleMouseMove = (e: MouseEvent) => {
    mouse.x = e.clientX;
    mouse.y = e.clientY;
  };
  window.addEventListener('mousemove', handleMouseMove);

  const handleResize = () => {
    width = window.innerWidth;
    height = window.innerHeight;
    canvas.width = width;
    canvas.height = height;
  };
  window.addEventListener('resize', handleResize);

  const animate = () => {
    ctx.clearRect(0, 0, width, height);
    ctx.fillStyle = 'rgba(150, 150, 150, 0.4)';
    ctx.lineWidth = 1;

    particles.forEach((p, index) => {
      p.x += p.vx;
      p.y += p.vy;

      if (p.x < 0 || p.x > width) p.vx *= -1;
      if (p.y < 0 || p.y > height) p.vy *= -1;

      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      ctx.fill();

      for (let j = index + 1; j < particles.length; j++) {
        const p2 = particles[j];
        const dx = p.x - p2.x;
        const dy = p.y - p2.y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        
        if (dist < 120) {
          ctx.beginPath();
          ctx.strokeStyle = `rgba(150, 150, 150, ${1 - dist / 120})`;
          ctx.moveTo(p.x, p.y);
          ctx.lineTo(p2.x, p2.y);
          ctx.stroke();
        }
      }

      const dxMouse = p.x - mouse.x;
      const dyMouse = p.y - mouse.y;
      const distMouse = Math.sqrt(dxMouse * dxMouse + dyMouse * dyMouse);
      
      if (distMouse < 150) {
        ctx.beginPath();
        ctx.strokeStyle = `rgba(100, 100, 255, ${0.8 - distMouse / 150})`; 
        ctx.moveTo(p.x, p.y);
        ctx.lineTo(mouse.x, mouse.y);
        ctx.stroke();
      }
    });

    animationFrameId = requestAnimationFrame(animate);
  };

  animate();

  onBeforeUnmount(() => {
    window.removeEventListener('mousemove', handleMouseMove);
    window.removeEventListener('resize', handleResize);
    cancelAnimationFrame(animationFrameId);
  });
});
</script>

<style scoped>
.glass-card {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(8px);
}
</style>