<template>
  <div class="bg-background text-on-surface min-h-screen">
    <header class="main-header">
      <div class="header-left">
        <span 
          class="material-symbols-outlined menu-icon-btn"
          @click="isMenuOpen = !isMenuOpen"
        >menu</span>
        <h1 class="header-title">東海通識課程推薦系統</h1>

        <!-- 下拉選單 -->
        <div v-if="isMenuOpen" class="menu-dropdown">
          <router-link to="/" class="menu-item">首頁</router-link>
          <router-link to="/manual-entry" class="menu-item">分數輸入</router-link>
          <a href="#" @click.prevent="goToResult" class="menu-item">結果查詢</a>
          <router-link to="/courses" class="menu-item">瀏覽所有課程</router-link>
        </div>
      </div>
      <nav class="header-right">
        <router-link to="/" class="home-btn">首頁</router-link>
      </nav>
    </header>

    <main class="max-w-[1440px] mx-auto px-container-margin py-xl pt-20">
      <div class="mb-xl">
        <h2 class="font-display-lg text-display-lg mb-2">分析結果</h2>
        <p class="text-on-surface-variant font-body-lg">
          學號：<span class="font-bold text-primary">{{ studentId }}</span> 根據您的核心能力分析，我們為您規劃了專屬的職能成長路徑。
        </p>
      </div>

      <!-- 載入中狀態 -->
      <div v-if="isLoading" class="text-center py-2xl">
        <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="mt-4 text-on-surface-variant">正在讀取分析結果...</p>
      </div>

      <!-- 錯誤或提示訊息 -->
      <div v-else-if="errorMessage" class="bg-error-container text-on-error-container p-lg rounded-xl mb-xl">
        <p class="font-bold mb-2">提示</p>
        <p>{{ errorMessage }}</p>
        <button @click="loadFallback" class="mt-3 px-4 py-1.5 bg-primary text-on-primary rounded-full text-sm font-medium hover:bg-primary-container transition-colors">
          使用預設模擬資料載入頁面
        </button>
      </div>

      <div v-else>
        <section class="mb-2xl">
          <div class="competency-grid">
            <div v-for="(val, key) in competencyScores" :key="key" class="glass-card p-lg rounded-xl border-l-4" :class="getBorderColor(key)">
              <h4 class="font-headline-md mb-sm">{{ val.name }}</h4>
              <span class="text-display-lg leading-none">{{ val.score }}</span>
            </div>
          </div>
        </section>

        <section>
          <div class="flex items-center justify-between mb-lg">
            <h3 class="font-headline-lg text-headline-lg">推薦通識課程</h3>
          </div>

          <!-- 強弱項篩選 -->
          <div class="filter-row">
            <span class="filter-label">職能分類：</span>
            <div class="filter-buttons">
              <button
                v-for="opt in strengthOptions" :key="opt.id"
                @click="activeStrength = opt.id"
                :class="['filter-btn', activeStrength === opt.id ? 'filter-btn-active' : '']"
              >{{ opt.label }}</button>
            </div>
          </div>
          
          <!-- 領域篩選 -->
          <div class="filter-row">
            <span class="filter-label">課程領域：</span>
            <div class="filter-buttons">
              <button 
                v-for="domain in domains" :key="domain.id"
                @click="activeDomain = domain.id"
                :class="['filter-btn', activeDomain === domain.id ? 'filter-btn-active' : '']"
              >{{ domain.label }}</button>
            </div>
          </div>

          <div v-if="filteredCourses.length === 0" class="empty-state">
            此分類下暫無推薦課程
          </div>
          <div v-else class="course-grid">
            <div 
              v-for="course in filteredCourses" :key="course.id"
              class="course-card"
            >
              <div class="course-header">
                <span class="course-semester">{{ course.semester }}</span>
                <a v-if="course.url" :href="course.url" target="_blank" rel="noopener noreferrer" class="font-headline-md course-link">
                  {{ course.name }}
                </a>
                <span v-else class="font-headline-md">{{ course.name }}</span>
              </div>
              <div class="course-meta">
                <div class="meta-item"><span class="material-symbols-outlined" style="font-size:18px;">person</span> {{ course.professor }}</div>
                <div class="meta-item"><span class="material-symbols-outlined" style="font-size:18px;">schedule</span> {{ course.time }}</div>
                <div class="meta-item"><span class="material-symbols-outlined" style="font-size:18px;">psychology</span> 對應能力：{{ course.powers?.map(p => powerCnMap[p] || p).join('、') }}</div>
              </div>
              <div class="course-reason">
                <p><strong>課程介紹：</strong>{{ course.outline }}</p>
              </div>
            </div>
          </div>
        </section>
      </div>
    </main>

    <!-- 點擊外部關閉選單的遮罩 -->
    <div v-if="isMenuOpen" @click="isMenuOpen = false" class="fixed inset-0 z-40"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const route = useRoute();
const router = useRouter();
const studentId = computed(() => (route.params.id as string) || '未設定學號');

const isLoading = ref(true);
const errorMessage = ref('');
const isMenuOpen = ref(false);

const goToResult = () => {
  const sid = prompt('請輸入您的學號查詢結果：', 's12490016');
  if (sid && sid.trim()) {
    router.push({ name: 'Result', params: { id: sid.trim() } });
  }
};

// 職能分數與課程資料
interface Competency {
  name: string;
  score: number;
}
const competencyScores = ref<Record<string, Competency>>({});
const courses = ref<any[]>([]);
const strongPowers = ref<string[]>([]);
const weakPowers = ref<string[]>([]);
const powerCnMap: Record<string, string> = {
  Execution: '開創力',
  Leadership: '執行力',
  Affability: '統御力',
  Innovation: '親和力',
  Adaptability: '應變力',
  Sensitivity: '敏感力'
};

const getBorderColor = (key: string) => {
  const colors: Record<string, string> = {
    execution: 'border-primary',
    leadership: 'border-secondary',
    affability: 'border-success-container',
    innovation: 'border-tertiary',
    adaptability: 'border-info',
    sensitivity: 'border-error'
  };
  return colors[key] || 'border-gray-300';
};

// 強弱項篩選
const activeStrength = ref('');
const strengthOptions = [
  { id: '', label: '全部' },
  { id: 'strong', label: '強項職能' },
  { id: 'weak', label: '弱項職能' }
];

// 領域篩選
const activeDomain = ref('');
const domains = [
  { id: '', label: '全部' },
  { id: 'humanities', label: '人文' },
  { id: 'social', label: '社會' },
  { id: 'natural', label: '自然' }
];

const filteredCourses = computed(() => {
  let result = courses.value;

  // 先依強弱項篩選
  if (activeStrength.value === 'strong') {
    result = result.filter(c =>
      c.powers && c.powers.some((p: string) => strongPowers.value.includes(p))
    );
  } else if (activeStrength.value === 'weak') {
    result = result.filter(c =>
      c.powers && c.powers.some((p: string) => weakPowers.value.includes(p))
    );
  }

  // 再依領域篩選
  if (activeDomain.value) {
    result = result.filter(c => c.domain === activeDomain.value);
  }

  return result;
});

// 載入 fallback 模擬資料
const loadFallback = () => {
  errorMessage.value = '';
  competencyScores.value = {
    execution: { name: '開創力', score: 8 },
    leadership: { name: '執行力', score: 7 },
    affability: { name: '統御力', score: 9 },
    innovation: { name: '親和力', score: 6 },
    adaptability:{ name: '應變力', score: 8 },
    sensitivity: { name: '敏感力', score: 5 }
  };
  strongPowers.value = ['Execution', 'Leadership', 'Affability', 'Innovation', 'Adaptability'];
  weakPowers.value = ['Sensitivity'];
  courses.value = [
    { id: 1, domain: 'natural', semester: '114年第2學期', name: '3102 自然：科學新知', professor: '劉德祥 教授', time: '二/3,4[SS101]', outline: '本課程介紹當代科學前沿知識，培養學生科學素養與跨領域思維能力。', powers: ['Execution', 'Innovation'] },
    { id: 2, domain: 'humanities', semester: '114年第2學期', name: '3007 人文：生命美學─藝術', professor: '朱先仙 教授', time: '三/3,4[AG122]', outline: '透過藝術欣賞與美學探討，豐富個人內涵，培養對生命與藝術的感知力。', powers: ['Sensitivity', 'Affability'] },
    { id: 3, domain: 'social', semester: '114年第2學期', name: '3163 社會：世界議題─東南亞', professor: '翁俊桔 教授', time: '五/6,7[HT007]', outline: '探討東南亞區域的政治、經濟與文化議題，增進國際視野與全球化理解。', powers: ['Leadership', 'Adaptability'] }
  ];
  isLoading.value = false;
};

// 從 API 獲取資料
const fetchResults = async () => {
  if (!route.params.id) {
    loadFallback();
    return;
  }
  
  try {
    const response = await fetch(`http://127.0.0.1:5000/api/get_student_results/${route.params.id}`);
    if (!response.ok) {
      if (response.status === 404) {
        throw new Error(`找不到學號 ${route.params.id} 的測驗資料，請先至「分數輸入」填寫。`);
      }
      throw new Error('無法從伺服器取得資料。');
    }
    const result = await response.json();
    competencyScores.value = result.competencyScores;
    courses.value = result.recommendedCourses;
    strongPowers.value = result.strongPowers || [];
    weakPowers.value = result.weakPowers || [];
    isLoading.value = false;
  } catch (error: any) {
    console.error(error);
    errorMessage.value = error.message || '連線後端 API 失敗。';
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchResults();
});
</script>

<style scoped>
.competency-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.course-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
}

.filter-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.filter-label {
  color: var(--text-secondary);
  font-weight: 600;
  font-size: 14px;
  white-space: nowrap;
}

.filter-buttons {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.filter-btn {
  padding: 8px 16px;
  border-radius: 9999px;
  border: 1px solid var(--border-light);
  background: transparent;
  color: var(--text-main);
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
}

.filter-btn:hover {
  background-color: rgba(22, 67, 171, 0.05);
}

.filter-btn-active {
  background-color: var(--primary) !important;
  color: #fff !important;
  border-color: var(--primary) !important;
}

.empty-state {
  text-align: center;
  padding: 32px;
  background: var(--bg-sidebar);
  border-radius: 12px;
  border: 1px solid var(--border-light);
  color: var(--text-secondary);
}

.course-card {
  display: flex;
  flex-direction: column;
  background: var(--bg-card);
  border: 1px solid var(--border-light);
  border-radius: 12px;
  overflow: hidden;
  padding: 24px;
  transition: box-shadow 0.2s;
  height: 310px;
}

.course-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
}

.course-header {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 8px;
  flex-shrink: 0;
}

.course-link {
  color: inherit;
  text-decoration: none;
  transition: color 0.2s, text-decoration 0.2s;
  cursor: pointer;
}

.course-link:hover {
  color: var(--primary);
  text-decoration: underline;
}

.course-semester {
  font-size: 12px;
  color: var(--primary);
  font-weight: 500;
}

.course-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
  color: var(--text-secondary);
  margin-bottom: 16px;
  flex-shrink: 0;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.course-reason {
  margin-top: auto;
  padding-top: 16px;
  border-top: 1px solid var(--border-light);
  color: var(--text-secondary);
  font-size: 14px;
  font-style: italic;
  overflow-y: auto;
  min-height: 0;
  flex: 1;
}

.course-reason::-webkit-scrollbar {
  width: 6px;
}

.course-reason::-webkit-scrollbar-track {
  background: transparent;
}

.course-reason::-webkit-scrollbar-thumb {
  background: #cccccc;
  border-radius: 3px;
}

.course-reason::-webkit-scrollbar-thumb:hover {
  background: #b0b0b0;
}

@media (max-width: 768px) {
  .competency-grid {
    grid-template-columns: 1fr;
  }
  .course-grid {
    grid-template-columns: 1fr;
  }
  .filter-row {
    flex-direction: column;
    align-items: flex-start;
  }
}

.main-header {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 56px;
  background-color: var(--bg-card, #ffffff);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 var(--container-margin, 24px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  border-bottom: 1px solid var(--border-light, #e9ecef);
  z-index: 50;
  box-sizing: border-box;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
  position: relative;
}

.header-title {
  font-size: 20px;
  font-weight: 700;
  color: var(--primary);
  margin: 0;
}

.menu-icon-btn {
  font-size: 24px;
  color: var(--primary);
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  transition: background-color 0.2s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.menu-icon-btn:hover {
  background-color: rgba(22, 67, 171, 0.05);
}

.menu-dropdown {
  position: absolute;
  top: 48px;
  left: 0;
  width: 192px;
  background-color: var(--bg-card, #ffffff);
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border: 1px solid var(--border-light, #e9ecef);
  overflow: hidden;
  z-index: 100;
}

.menu-item {
  display: block;
  padding: 12px 16px;
  color: var(--text-main);
  text-decoration: none;
  font-size: 14px;
  transition: background-color 0.2s, color 0.2s;
}

.menu-item:hover {
  background-color: rgba(22, 67, 171, 0.05);
  color: var(--primary);
}

.header-right {
  display: flex;
  align-items: center;
}

.home-btn {
  display: inline-block;
  color: var(--primary) !important;
  font-weight: 600;
  font-size: 14px;
  padding: 8px 16px;
  background-color: rgba(22, 67, 171, 0.08);
  border-radius: 8px;
  text-decoration: none;
  transition: background-color 0.2s;
}

.home-btn:hover {
  background-color: rgba(22, 67, 171, 0.15);
}
</style>