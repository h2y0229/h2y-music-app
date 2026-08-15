/**
 * @file PlayerBar.ts
 * @description 하단 오디오 재생 제어 바 컴포넌트
 */

import { VFSEntry } from '../types/vfs';

export interface PlayerBarOptions {
  onPlayToggle: () => void;
  onPrev: () => void;
  onNext: () => void;
  onSeek: (percent: number) => void;
  onVolumeChange: (volume: number) => void;
}

export class PlayerBar {
  private container: HTMLElement;
  private options: PlayerBarOptions;
  private isMuted = false;
  private currentVolume = 0.8;
  public isPlaying = false;
  public duration = 0;
  public currentTime = 0;

  constructor(containerId: string, options: PlayerBarOptions) {
    const el = document.getElementById(containerId);
    if (!el) {
      throw new Error(`PlayerBar 컨테이너 요소를 찾을 수 없습니다: #${containerId}`);
    }
    this.container = el;
    this.options = options;
    this.render();
    this.bindEvents();
  }

  public setTrackInfo(track: VFSEntry | null, coverUrl?: string): void {
    const thumb = this.container.querySelector('#player-thumb');
    const title = this.container.querySelector('#player-title');
    const artist = this.container.querySelector('#player-artist');

    if (!track) {
      if (thumb) thumb.innerHTML = '🎵';
      if (title) title.textContent = '선택된 트랙 없음';
      if (artist) artist.textContent = '대기 중';
      return;
    }

    if (thumb) {
      thumb.innerHTML = coverUrl ? `<img src="${coverUrl}" style="width:100%;height:100%;object-fit:cover;" />` : '🎵';
    }
    if (title) title.textContent = track.name.replace(/\.[^/.]+$/, '');
    if (artist) artist.textContent = track.path.split('/')[0] || 'Unknown Artist';
  }

  public setPlayState(playing: boolean): void {
    this.isPlaying = playing;
    const playBtn = this.container.querySelector('#btn-play-pause');
    if (playBtn) {
      playBtn.innerHTML = playing ? '⏸' : '▶';
    }
  }

  public setProgress(currentSec: number, totalSec: number): void {
    this.currentTime = currentSec;
    this.duration = totalSec;

    const curLabel = this.container.querySelector('#time-current');
    const totalLabel = this.container.querySelector('#time-total');
    const fill = this.container.querySelector('#progress-fill') as HTMLElement;

    if (curLabel) curLabel.textContent = this.formatTime(currentSec);
    if (totalLabel) totalLabel.textContent = this.formatTime(totalSec);

    if (fill && totalSec > 0) {
      const pct = Math.min(100, Math.max(0, (currentSec / totalSec) * 100));
      fill.style.width = `${pct}%`;
    }
  }

  private formatTime(seconds: number): string {
    if (isNaN(seconds) || seconds < 0) return '00:00';
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }

  private render(): void {
    this.container.innerHTML = `
      <div class="current-track-info">
        <div id="player-thumb" class="album-cover-thumb">🎵</div>
        <div class="track-meta">
          <div id="player-title" class="track-title">선택된 트랙 없음</div>
          <div id="player-artist" class="track-artist">대기 중</div>
        </div>
      </div>

      <div class="player-controls-center">
        <div class="playback-buttons">
          <button id="btn-shuffle" class="btn-icon" title="셔플" style="font-size: 0.95rem;">🔀</button>
          <button id="btn-prev" class="btn-icon" title="이전 곡">⏮</button>
          <button id="btn-play-pause" class="btn-primary-play" title="재생/일시정지">▶</button>
          <button id="btn-next" class="btn-icon" title="다음 곡">⏭</button>
          <button id="btn-repeat" class="btn-icon" title="반복 재생" style="font-size: 0.95rem;">🔁</button>
        </div>

        <div class="timeline-container">
          <span id="time-current" class="time-label">00:00</span>
          <div id="progress-bar" class="progress-bar-wrap">
            <div id="progress-fill" class="progress-fill"></div>
          </div>
          <span id="time-total" class="time-label">00:00</span>
        </div>
      </div>

      <div class="player-controls-right">
        <button id="btn-eq" class="btn-icon" title="10-Band 이퀄라이저" style="font-size: 1rem;">🎛️</button>
        <div class="volume-slider-wrap">
          <button id="btn-volume-icon" class="btn-icon" style="width: 32px; height: 32px; font-size: 0.9rem;">🔊</button>
          <input type="range" id="volume-slider" class="volume-slider" min="0" max="1" step="0.01" value="0.8" />
        </div>
      </div>
    `;
  }

  private bindEvents(): void {
    const playBtn = this.container.querySelector('#btn-play-pause');
    const prevBtn = this.container.querySelector('#btn-prev');
    const nextBtn = this.container.querySelector('#btn-next');
    const progressBar = this.container.querySelector('#progress-bar') as HTMLElement;
    const volSlider = this.container.querySelector('#volume-slider') as HTMLInputElement;
    const volIcon = this.container.querySelector('#btn-volume-icon');

    playBtn?.addEventListener('click', () => this.options.onPlayToggle());
    prevBtn?.addEventListener('click', () => this.options.onPrev());
    nextBtn?.addEventListener('click', () => this.options.onNext());

    progressBar?.addEventListener('click', (e: MouseEvent) => {
      const rect = progressBar.getBoundingClientRect();
      const clickX = e.clientX - rect.left;
      const pct = Math.max(0, Math.min(1, clickX / rect.width));
      this.options.onSeek(pct);
    });

    volSlider?.addEventListener('input', (e: Event) => {
      const val = parseFloat((e.target as HTMLInputElement).value);
      this.currentVolume = val;
      this.options.onVolumeChange(val);
    });

    volIcon?.addEventListener('click', () => {
      this.isMuted = !this.isMuted;
      if (this.isMuted) {
        this.options.onVolumeChange(0);
        volSlider.value = '0';
        volIcon.textContent = '🔇';
      } else {
        this.options.onVolumeChange(this.currentVolume);
        volSlider.value = String(this.currentVolume);
        volIcon.textContent = '🔊';
      }
    });
  }
}
