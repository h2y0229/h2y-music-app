/**
 * @file TrackList.ts
 * @description VFS 오디오 트랙 목록 및 가상 디렉토리 뷰어 컴포넌트
 */

import { VFSEntry } from '../types/vfs';

export interface TrackListOptions {
  onTrackSelect: (track: VFSEntry) => void;
}

export class TrackList {
  private container: HTMLElement;
  private tracks: VFSEntry[] = [];
  private activeTrackId: string | null = null;
  private onTrackSelect: (track: VFSEntry) => void;
  private filterQuery = '';

  constructor(containerId: string, options: TrackListOptions) {
    const el = document.getElementById(containerId);
    if (!el) {
      throw new Error(`TrackList 컨테이너 요소를 찾을 수 없습니다: #${containerId}`);
    }
    this.container = el;
    this.onTrackSelect = options.onTrackSelect;
    this.render();
  }

  /** 트랙 목록 데이터 갱신 */
  public setTracks(tracks: VFSEntry[]): void {
    this.tracks = tracks;
    this.renderList();
  }

  /** 활성 트랙 설정 */
  public setActiveTrack(trackId: string | null): void {
    this.activeTrackId = trackId;
    this.container.querySelectorAll('.track-item').forEach(item => {
      if (item.getAttribute('data-id') === trackId) {
        item.classList.add('active');
      } else {
        item.classList.remove('active');
      }
    });
  }

  private formatBytes(bytes: number): string {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  }

  private render(): void {
    this.container.innerHTML = `
      <div style="display: flex; flex-direction: column; height: 100%; gap: 10px;">
        <div style="position: relative;">
          <input 
            type="text" 
            id="track-search-input" 
            placeholder="트랙 검색 (제목, 경로)..." 
            style="width: 100%; padding: 8px 12px; background: rgba(255, 255, 255, 0.05); border: 1px solid var(--glass-border); border-radius: var(--radius-sm); color: var(--text-primary); font-size: 0.82rem; outline: none;" 
          />
        </div>
        <div id="track-items-box" class="track-list-container">
          <div style="text-align: center; padding: 40px 16px; color: var(--text-muted); font-size: 0.85rem;">
            압축 파일을 불러오면 여기에 오디오 트랙이 표시됩니다.
          </div>
        </div>
      </div>
    `;

    const searchInput = this.container.querySelector('#track-search-input') as HTMLInputElement;
    if (searchInput) {
      searchInput.addEventListener('input', (e: Event) => {
        this.filterQuery = (e.target as HTMLInputElement).value.toLowerCase();
        this.renderList();
      });
    }
  }

  private renderList(): void {
    const box = this.container.querySelector('#track-items-box');
    if (!box) return;

    const filtered = this.tracks.filter(t => 
      t.name.toLowerCase().includes(this.filterQuery) || 
      t.path.toLowerCase().includes(this.filterQuery)
    );

    if (filtered.length === 0) {
      box.innerHTML = `
        <div style="text-align: center; padding: 30px 16px; color: var(--text-muted); font-size: 0.85rem;">
          ${this.tracks.length === 0 ? '재생 가능한 오디오 트랙이 없습니다.' : '일치하는 검색 결과가 없습니다.'}
        </div>
      `;
      return;
    }

    box.innerHTML = filtered.map((track, idx) => {
      const isActive = track.id === this.activeTrackId;
      const format = (track.audioFormat || 'audio').toUpperCase();
      const sizeStr = this.formatBytes(track.size);

      return `
        <div class="track-item ${isActive ? 'active' : ''}" data-id="${track.id}">
          <span class="track-index">${String(idx + 1).padStart(2, '0')}</span>
          <div class="track-name" title="${track.path}">
            <div style="font-weight: 500;">${track.name}</div>
            <div style="font-size: 0.72rem; color: var(--text-muted);">${track.path}</div>
          </div>
          <span class="track-badge">${format}</span>
          <span style="font-family: var(--font-mono); font-size: 0.72rem; color: var(--text-muted);">${sizeStr}</span>
        </div>
      `;
    }).join('');

    // 클릭 이벤트 바인딩
    box.querySelectorAll('.track-item').forEach(item => {
      item.addEventListener('click', () => {
        const id = item.getAttribute('data-id');
        const track = this.tracks.find(t => t.id === id);
        if (track) {
          this.setActiveTrack(track.id);
          this.onTrackSelect(track);
        }
      });
    });
  }
}
