/**
 * @file DropZone.ts
 * @description 아카이브 파일 드래그앤드롭 및 파일 선택 컴포넌트
 */

export interface DropZoneOptions {
  onFileSelected: (file: File) => void;
}

export class DropZone {
  private element: HTMLElement;
  private fileInput!: HTMLInputElement;
  private onFileSelected: (file: File) => void;

  constructor(containerId: string, options: DropZoneOptions) {
    const el = document.getElementById(containerId);
    if (!el) {
      throw new Error(`DropZone 컨테이너 요소를 찾을 수 없습니다: #${containerId}`);
    }
    this.element = el;
    this.onFileSelected = options.onFileSelected;
    this.render();
    this.bindEvents();
  }

  private render(): void {
    this.element.innerHTML = `
      <div class="dropzone-box glass-card" style="padding: 24px 16px; text-align: center; border: 2px dashed var(--glass-border); cursor: pointer; transition: all var(--transition-normal); border-radius: var(--radius-md);">
        <input type="file" id="archive-file-input" accept=".zip,.7z,.rar,.tar,application/zip,application/x-zip-compressed" style="display: none;" />
        <div style="font-size: 2.2rem; margin-bottom: 8px; filter: drop-shadow(0 0 10px rgba(0, 240, 255, 0.4));">📁</div>
        <div style="font-size: 0.95rem; font-weight: 600; margin-bottom: 4px;">압축 파일 드롭 또는 클릭</div>
        <p style="font-size: 0.78rem; color: var(--text-muted); margin-bottom: 12px;">ZIP, 7Z, RAR 대용량 무해제 직접 재생</p>
        <div style="display: flex; justify-content: center; gap: 6px; flex-wrap: wrap;">
          <span class="badge-neon">ZIP</span>
          <span class="badge-purple">7Z</span>
          <span class="badge-neon">RAR</span>
          <span class="badge-purple">TAR</span>
        </div>
      </div>
    `;

    this.fileInput = this.element.querySelector('#archive-file-input') as HTMLInputElement;
  }

  private bindEvents(): void {
    const dropBox = this.element.querySelector('.dropzone-box') as HTMLElement;

    dropBox.addEventListener('click', () => {
      this.fileInput.click();
    });

    this.fileInput.addEventListener('change', (e: Event) => {
      const target = e.target as HTMLInputElement;
      if (target.files && target.files.length > 0) {
        this.onFileSelected(target.files[0]);
      }
    });

    // 드래그 앤 드롭 이벤트
    ['dragenter', 'dragover'].forEach(eventName => {
      dropBox.addEventListener(eventName, (e: Event) => {
        e.preventDefault();
        e.stopPropagation();
        dropBox.classList.add('dropzone-active');
      });
    });

    ['dragleave', 'drop'].forEach(eventName => {
      dropBox.addEventListener(eventName, (e: Event) => {
        e.preventDefault();
        e.stopPropagation();
        dropBox.classList.remove('dropzone-active');
      });
    });

    dropBox.addEventListener('drop', (e: DragEvent) => {
      if (e.dataTransfer && e.dataTransfer.files.length > 0) {
        const file = e.dataTransfer.files[0];
        this.onFileSelected(file);
      }
    });
  }

  /**
   * 로딩 상태 메시지 표시
   */
  public setLoading(loading: boolean, text = 'VFS 헤더 인덱싱 중...'): void {
    const dropBox = this.element.querySelector('.dropzone-box') as HTMLElement;
    if (!dropBox) return;

    if (loading) {
      dropBox.style.pointerEvents = 'none';
      dropBox.innerHTML = `
        <div style="padding: 16px 0; display: flex; flex-direction: column; align-items: center; gap: 8px;">
          <div style="font-size: 1.8rem; animation: spin 1s infinite linear;">⚡</div>
          <span style="font-size: 0.85rem; font-weight: 600; color: var(--accent-cyan);">${text}</span>
          <span style="font-size: 0.75rem; color: var(--text-muted);">Range Read 가상 디렉토리 구축 중</span>
        </div>
      `;
    } else {
      dropBox.style.pointerEvents = 'auto';
      this.render();
      this.bindEvents();
    }
  }
}
