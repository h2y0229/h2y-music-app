/**
 * @file AppShell.ts
 * @description 프리미엄 3단 Glassmorphism UI 셸 렌더러
 */

export class AppShell {
  private rootElement: HTMLElement;

  constructor(rootId: string) {
    const el = document.getElementById(rootId);
    if (!el) {
      throw new Error(`루트 요소를 찾을 수 없습니다: #${rootId}`);
    }
    this.rootElement = el;
    this.render();
  }

  private render(): void {
    this.rootElement.innerHTML = `
      <div class="app-wrapper">
        <!-- 1. 상단 글로벌 네비게이션 헤더 -->
        <header class="app-header glass-panel">
          <div class="brand-section">
            <span class="brand-logo">⚡</span>
            <div>
              <div class="brand-title">h2y Music Player</div>
              <div class="brand-subtitle">압축 파일 무해제 온디맨드 스트리밍 플레이어</div>
            </div>
          </div>
          <div class="header-status">
            <span class="badge-neon">● VFS Ready</span>
            <span class="badge-purple">Node v24 LTS</span>
          </div>
        </header>

        <!-- 2. 중앙 3단 메인 작업 영역 -->
        <main class="app-body">
          <!-- 좌측 사이드바: 드롭존 및 VFS 트랙 트리 -->
          <aside class="sidebar-panel glass-panel">
            <div class="sidebar-header">
              <span class="sidebar-title">Archive Explorer</span>
            </div>
            <div id="dropzone-container"></div>
            <div class="sidebar-header" style="margin-top: 6px;">
              <span class="sidebar-title">Track List (<span id="track-count-badge">0</span>)</span>
            </div>
            <div id="tracklist-container" style="flex: 1; min-height: 0;"></div>
          </aside>

          <!-- 중앙 메인 뷰어 & 비주얼라이저 -->
          <section id="main-player-container" class="main-view-panel glass-panel"></section>
        </main>

        <!-- 3. 하단 미디어 재생 컨트롤러 바 -->
        <footer id="player-bar-container" class="player-bar-panel glass-panel"></footer>
      </div>
    `;
  }
}
