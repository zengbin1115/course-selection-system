<template>
  <div class="bg-background text-on-surface min-h-screen">
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

    <main style="padding-top: 100px;" class="max-w-7xl mx-auto px-container-margin min-h-screen pb-20 relative z-10">
      <section class="mb-6">
        <div class="relative max-w-xl">
          <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant text-xl">search</span>
          <input
            v-model="searchKeyword"
            type="text"
            placeholder="搜尋課名、教師或課程介紹..."
            class="w-full pl-10 pr-10 py-3 rounded-full border-2 border-outline-variant bg-surface text-on-surface focus:outline-none focus:border-primary transition-colors"
          />
          <button
            v-if="searchKeyword"
            @click="searchKeyword = ''"
            class="absolute right-3 top-1/2 -translate-y-1/2 text-on-surface-variant hover:text-primary"
          >
            <span class="material-symbols-outlined text-xl">close</span>
          </button>
        </div>
      </section>

      <section class="mb-6">
        <h3 class="text-lg font-semibold text-on-surface mb-4">依領域篩選課程</h3>
        <div class="flex flex-wrap gap-3">
          <button
            v-for="domain in domainTabs"
            :key="domain.id"
            @click="toggleDomain(domain.id)"
            :class="[
              'px-5 py-2 rounded-full text-sm font-semibold border-2 transition-all duration-200 cursor-pointer',
              selectedDomains.includes(domain.id)
                ? 'bg-primary text-on-primary border-primary shadow-md scale-105'
                : 'bg-surface text-on-surface-variant border-outline-variant hover:border-primary hover:text-primary'
            ]"
          >
            {{ domain.label }}
          </button>
        </div>
      </section>

      <section class="mb-8">
        <h3 class="text-lg font-semibold text-on-surface mb-4">依職能篩選課程</h3>
        <div class="flex flex-wrap gap-3">
          <button
            v-for="power in powerTags"
            :key="power.key"
            @click="togglePower(power.key)"
            :class="[
              'px-5 py-2 rounded-full text-sm font-semibold border-2 transition-all duration-200 cursor-pointer',
              selectedPowers.includes(power.key)
                ? 'bg-primary text-on-primary border-primary shadow-md scale-105'
                : 'bg-surface text-on-surface-variant border-outline-variant hover:border-primary hover:text-primary'
            ]"
          >
            {{ power.label }}
          </button>
          <button
            @click="toggleUnclassified"
            :class="[
              'px-5 py-2 rounded-full text-sm font-semibold border-2 transition-all duration-200 cursor-pointer',
              showUnclassifiedOnly
                ? 'bg-primary text-on-primary border-primary shadow-md scale-105'
                : 'bg-surface text-on-surface-variant border-outline-variant hover:border-primary hover:text-primary'
            ]"
          >
            未分類職能
          </button>
          <button
            v-if="selectedPowers.length > 0 || selectedDomains.length > 0 || showUnclassifiedOnly || searchKeyword"
            @click="selectedPowers = []; selectedDomains = []; showUnclassifiedOnly = false; searchKeyword = ''"
            class="px-5 py-2 rounded-full text-sm font-semibold border-2 border-red-300 text-red-500 hover:bg-red-50 transition-all duration-200 cursor-pointer"
          >
            ✕ 清除篩選
          </button>
        </div>
        <p class="mt-3 text-sm text-on-surface-variant text-gray-800">
          <span v-if="selectedPowers.length === 0 && selectedDomains.length === 0 && !showUnclassifiedOnly && !searchKeyword">目前顯示所有課程（共 {{ courses.length }} 門）</span>
          <span v-else>篩選結果：共 {{ filteredCourses.length }} 門課程</span>
        </p>
      </section>

      <div v-if="filteredCourses.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="course in filteredCourses" :key="course.class_id" class="bg-surface-container-lowest rounded-xl p-6 shadow-sm border border-outline-variant hover:border-primary hover:shadow-md transition-all duration-300 flex flex-col">
          <div class="mb-4">
            <h3 class="text-xl font-bold text-on-surface mb-1">{{ course.class_name_chinese }}</h3>
            <p class="text-sm text-on-surface-variant line-clamp-1">{{ course.class_name_english || '無英文名稱' }}</p>
          </div>
          
          <div class="text-sm text-on-surface-variant mb-4 space-y-2 flex-grow">
            <div class="flex items-center gap-2">
              <span class="material-symbols-outlined text-base">person</span>
              <span>{{ course.teacher_name || '未指定授課教師' }}</span>
            </div>
            <div class="flex items-center gap-2">
              <span class="material-symbols-outlined text-base">domain</span>
              <span>{{ course.department || '未指定開課單位' }}</span>
            </div>
            <div class="flex items-center gap-2">
              <span class="material-symbols-outlined text-base">schedule</span>
              <span>{{ course.classtime_classroom || '未定' }}</span>
            </div>
            <div class="flex items-center gap-2">
              <span class="material-symbols-outlined text-base">school</span>
              <span>學分：{{ course.credits || '未知' }}</span>
            </div>
          </div>

          <div v-if="course.powers && course.powers.length > 0" class="mb-3">
            <span class="px-3 py-1 bg-primary-container text-on-primary-container text-xs rounded-full font-medium">
              {{ course.powers.map(p => powerLabelMap[p] || p).join(' / ') }}
            </span>
          </div>

          <div class="mt-auto border-t border-outline-variant pt-4">
            <h4 class="text-sm font-semibold text-on-surface mb-2">課程介紹</h4>
            <div class="text-sm text-on-surface-variant leading-relaxed">
              <div v-if="course.course_outline" class="max-h-32 overflow-y-auto [&::-webkit-scrollbar]:w-1.5 [&::-webkit-scrollbar-track]:bg-transparent [&::-webkit-scrollbar-thumb]:bg-gray-300 [&::-webkit-scrollbar-thumb]:rounded-full pr-2">
                <p>{{ course.course_outline }}</p>
              </div>
              <p v-else class="italic">無相關內容</p>
            </div>

            <div v-if="course.course_url" class="mt-3 text-right">
              <a
                :href="course.course_url"
                target="_blank"
                class="text-sm text-primary inline-flex items-center gap-0.5 hover:underline"
              >
                課程詳情 <span class="material-symbols-outlined text-sm">open_in_new</span>
              </a>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-20 text-on-surface-variant">
        <span class="material-symbols-outlined text-4xl mb-2">search_off</span>
        <p>目前沒有符合此篩選條件的課程。</p>
      </div>
    </main>

    <div v-if="isMenuOpen" @click="isMenuOpen = false" class="fixed inset-0 z-40"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
import { Link } from '@inertiajs/vue3'; // 🌟 記得引入 Inertia 的 Link

interface Course {
  class_id: number;
  class_name_chinese: string;
  class_name_english: string;
  teacher_name: string;
  department: string;
  credits: string;
  classtime_classroom: string;
  course_outline: string;
  course_url: string;
  abilities: string[];
  powers: string[];
}

// 🌟 1. 接收 Laravel Controller 傳遞過來的 props
const props = defineProps<{
  initialCourses: Course[];
}>();

// 英文 -> 中文對照表
const powerLabelMap: Record<string, string> = {
  'Execution': '執行力',
  'Leadership': '領導力',
  'Affability': '親和力',
  'Innovation': '開創力',
  'Adaptability': '應變力',
  'Sensitivity': '敏銳力',
};

// 六大職能標籤定義
const powerTags = [
  { key: 'Execution', label: '執行力' },
  { key: 'Leadership', label: '領導力' },
  { key: 'Affability', label: '親和力' },
  { key: 'Innovation', label: '開創力' },
  { key: 'Adaptability', label: '應變力' },
  { key: 'Sensitivity', label: '敏銳力' },
];

const isMenuOpen = ref(false);

// 🌟 2. 直接把接收到的資料丟進 courses 裡
const courses = ref<Course[]>(props.initialCourses || []);
const selectedPowers = ref<string[]>([]);
const showUnclassifiedOnly = ref(false);
const searchKeyword = ref('');

// 領域篩選（人文領域 / 自然領域 / 社會領域），資料庫 department 欄位本身就是這三個值之一
// 改成多選：可以同時勾選多個領域
const selectedDomains = ref<string[]>([]);
const domainTabs = [
  { id: '人文領域', label: '人文領域' },
  { id: '自然領域', label: '自然領域' },
  { id: '社會領域', label: '社會領域' },
];

// 切換領域選取
const toggleDomain = (domain: string) => {
  const idx = selectedDomains.value.indexOf(domain);
  if (idx === -1) {
    selectedDomains.value.push(domain);
  } else {
    selectedDomains.value.splice(idx, 1);
  }
};

// 切換「未分類職能」模式，開啟時清空已選的職能標籤，避免狀態衝突
const toggleUnclassified = () => {
  showUnclassifiedOnly.value = !showUnclassifiedOnly.value;
  if (showUnclassifiedOnly.value) {
    selectedPowers.value = [];
  }
};

// 切換標籤選取
const togglePower = (power: string) => {
  showUnclassifiedOnly.value = false; // 選擇特定職能時，自動退出「未分類」模式
  const idx = selectedPowers.value.indexOf(power);
  if (idx === -1) {
    selectedPowers.value.push(power);
  } else {
    selectedPowers.value.splice(idx, 1);
  }
};

// 計算屬性：根據選取的領域 + 職能標籤 + 搜尋關鍵字篩選課程
const filteredCourses = computed(() => {
  const keyword = searchKeyword.value.trim().toLowerCase();

  return courses.value.filter(course => {
    // 領域條件（聯集/OR）：沒勾選任何領域時不限制；勾選了，課程只要符合其中一個領域即算通過
    const matchDomain = selectedDomains.value.length === 0 ||
      selectedDomains.value.includes(course.department);

    // 搜尋條件：比對課名（中英）、教師、課程介紹，任一欄位包含關鍵字即算通過
    const matchSearch = keyword === '' || [
      course.class_name_chinese,
      course.class_name_english,
      course.teacher_name,
      course.course_outline,
    ].some(field => (field || '').toLowerCase().includes(keyword));

    // 未分類職能：開啟時只顯示完全沒有任何職能標籤的課程，並且會跳過其他職能標籤的篩選
    if (showUnclassifiedOnly.value) {
      const isUnclassified = !course.powers || course.powers.length === 0;
      return matchDomain && matchSearch && isUnclassified;
    }

    // 職能條件（交集/AND）：沒選任何職能標籤時不限制；選了則該課程要包含所有被選取的職能
    // 如果你想改成「聯集(OR)」，把 every 改成 some 就可以了！
    const matchPower = selectedPowers.value.length === 0 ||
      selectedPowers.value.every(p => course.powers && course.powers.includes(p));

    return matchDomain && matchSearch && matchPower;
  });
});
// ==========================================
// 🌟 背景粒子邏輯
// ==========================================
const canvasRef = ref<HTMLCanvasElement | null>(null);
let animationFrameId: number;

onMounted (() => {
  // 1. 初始化畫布 (Canvas)
  const canvas = canvasRef.value;
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  // 設定畫布大小為目前視窗的寬高
  let width = window.innerWidth;
  let height = window.innerHeight;
  canvas.width = width;
  canvas.height = height;

  const particles: any[] = [];
  
  // ⚙️ 【可調整】粒子的總數量
  // 數值越大：畫面越擁擠、線條越密集（但太高可能會讓網頁變卡）
  // 數值越小：畫面越乾淨清爽
  const particleCount = 50; 

  // 滑鼠的初始位置（設為 -1000 是為了讓一開始畫面沒有滑鼠干擾）
  const mouse = { x: -1000, y: -1000 };

  // 2. 隨機生成所有的粒子
  for (let i = 0; i < particleCount; i++) {
    particles.push({
      x: Math.random() * width,  // 隨機的 X 座標
      y: Math.random() * height, // 隨機的 Y 座標
      
      // ⚙️ 【可調整】粒子的移動速度 (vx 是水平速度, vy 是垂直速度)
      // 目前的 1.5 是最大速度。如果把 1.5 改成 3.0，粒子就會飛得兩倍快！
      // 如果改成 0.5，粒子就會像灰塵一樣緩慢飄動。
      vx: (Math.random() - 0.5) * 3.0,
      vy: (Math.random() - 0.5) * 3.0,
      
      // ⚙️ 【可調整】粒子(圓點)的半徑大小
      // Math.random() * 2 + 1 代表半徑介於 1px 到 3px 之間
      // 如果想要大一點的圓點，可以改成 Math.random() * 4 + 2
      radius: Math.random() * 2 + 1 
    });
  }

  // 3. 監聽滑鼠移動，隨時更新滑鼠的座標
  const handleMouseMove = (e: MouseEvent) => {
    mouse.x = e.clientX;
    mouse.y = e.clientY;
  };
  window.addEventListener('mousemove', handleMouseMove);

  // 當瀏覽器視窗大小改變時，重新調整畫布大小
  const handleResize = () => {
    width = window.innerWidth;
    height = window.innerHeight;
    canvas.width = width;
    canvas.height = height;
  };
  window.addEventListener('resize', handleResize);

  // 4. 動畫的核心迴圈 (每一幀都會執行一次)
  const animate = () => {
    // 每次畫新的一幀前，先把舊的畫面擦乾淨
    ctx.clearRect(0, 0, width, height);
    
    // 🎨 【可調整】圓點粒子的顏色與透明度
    // 目前是灰色 'rgba(150, 150, 150, 0.4)'
    // 如果要換成藍色，可以改為 'rgba(59, 130, 246, 0.5)'
    ctx.fillStyle = 'rgba(150, 150, 150, 0.4)';
    
    // ⚙️ 【可調整】所有連線的粗細
    // 預設是 1px。如果改成 2，線條會變得很粗很明顯
    ctx.lineWidth = 1;

    // 處理每一個粒子的移動與繪製
    particles.forEach((p, index) => {
      // 讓粒子依照自己的速度移動
      p.x += p.vx;
      p.y += p.vy;

      // 如果粒子撞到螢幕左邊或右邊，就反彈 (速度乘上 -1)
      if (p.x < 0 || p.x > width) p.vx *= -1;
      // 如果粒子撞到螢幕上面或下面，就反彈
      if (p.y < 0 || p.y > height) p.vy *= -1;

      // 把圓點畫出來
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      ctx.fill();

      // 5. 繪製：粒子與粒子之間的連線
      for (let j = index + 1; j < particles.length; j++) {
        const p2 = particles[j];
        const dx = p.x - p2.x;
        const dy = p.y - p2.y;
        const dist = Math.sqrt(dx * dx + dy * dy); // 計算兩個粒子的距離
        
        // ⚙️ 【可調整】粒子之間產生連線的「感應距離」
        // 目前是 120。如果改成 200，即使相隔很遠的粒子也會連線，畫面會像蜘蛛網一樣密集。
        if (dist < 150) {
          ctx.beginPath();
          // 🎨 【可調整】粒子間連線的顏色
          // 後面的 `${1 - dist / 120}` 是一個數學公式，代表「距離越遠，透明度越低(越淡)」
          ctx.strokeStyle = `rgba(150, 150, 150, ${1 - dist / 120})`;
          ctx.moveTo(p.x, p.y);
          ctx.lineTo(p2.x, p2.y);
          ctx.stroke();
        }
      }

      // 6. 繪製：粒子與「滑鼠」之間的連線
      const dxMouse = p.x - mouse.x;
      const dyMouse = p.y - mouse.y;
      const distMouse = Math.sqrt(dxMouse * dxMouse + dyMouse * dyMouse); // 計算粒子離滑鼠多遠
      
      // ⚙️ 【可調整】滑鼠的「吸附/感應距離」
      // 目前是 150。改成 300 的話，滑鼠的引力範圍會變得超大！
      if (distMouse < 150) {
        ctx.beginPath();
        // 🎨 【可調整】滑鼠互動連線的顏色
        // 預設是偏紫色 'rgba(100, 100, 255, ...)'
        // 後面的 0.8 是最大透明度（讓它看起來比普通的線更明顯亮眼）
        ctx.strokeStyle = `rgba(100, 100, 255, ${0.8 - distMouse / 150})`; 
        ctx.moveTo(p.x, p.y);
        ctx.lineTo(mouse.x, mouse.y);
        ctx.stroke();
      }
    });

    // 不斷呼叫自己，讓畫面一直動下去
    animationFrameId = requestAnimationFrame(animate);
  };

  animate(); // 啟動動畫

  // 離開這個頁面時，記得清除監聽器跟動畫，避免網頁變卡或當機
  onBeforeUnmount(() => {
    window.removeEventListener('mousemove', handleMouseMove);
    window.removeEventListener('resize', handleResize);
    cancelAnimationFrame(animationFrameId);
  });
});
</script>