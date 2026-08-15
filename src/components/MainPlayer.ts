/**
 * @file MainPlayer.ts
 * @description 중앙 메인 플레이어 (앨범 커버, 오디오 비주얼라이저, 동기화 가사 및 메타정보)
 */

import { VFSEntry } from '../types/vfs';

export class MainPlayer {
  private container: HTMLElement;
  private currentTrack: VFSEntry | null = null;
  private isPlaying = false;

  constructor(containerId: string) {
    const el = document.getElementById(containerId);
    if (!el) {
      throw new Error(`MainPlayer 컨테이너 요소를 찾을 수 없습니다: #${containerId}`);
    }
    this.container = el;
    this.render();
  }

  public setTrack(track: VFSEntry | null, coverUrl?: string): void {
    this.currentTrack = track;
    this.render(coverUrl);
  }

  public setPlaying(playing: boolean): void {
    this.isPlaying = playing;
    const disc = this.container.querySelector('.vinyl-disc') as HTMLElement;
    if (disc) {
      if (playing) {
        disc.classList.add('playing');
      } else {
        disc.classList.remove('playing');
      }
    }
  }

  private render(coverUrl?: string): void {
    if (!this.currentTrack) {
      this.container.innerHTML = `
        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; text-align: center; gap: 20px; max-width: 480px;">
          <div style="position: relative; width: 140px; height: 140px; border-radius: 50%; background: linear-gradient(135deg, rgba(0, 240, 255, 0.1), rgba(168, 85, 247, 0.1)); border: 2px dashed rgba(255, 255, 255, 0.15); display: flex; align-items: center; justify-content: center; font-size: 3.5rem;">
            🎧
          </div>
          <div>
            <h2 style="font-size: 1.4rem; font-weight: 700; margin-bottom: 8px;">선택된 트랙이 없습니다</h2>
            <p style="font-size: 0.88rem; color: var(--text-muted); line-height: 1.6;">
              좌측에서 압축 파일(ZIP)을 드롭한 후 재생할 오디오 트랙을 클릭하면 무해제 온디맨드 스트리밍이 시작됩니다.
            </p>
          </div>
          <div style="display: flex; gap: 10px;">
            <span class="badge-neon">⚡ VFS Zero-Disk</span>
            <span class="badge-purple">🎶 Web Audio Engine</span>
          </div>
        </div>
      `;
      return;
    }

    const title = this.currentTrack.name.replace(/\.[^/.]+$/, '');
    const format = (this.currentTrack.audioFormat || 'AUDIO').toUpperCase();

    this.container.innerHTML = `
      <style>
        @keyframes rotateDisc {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
        .vinyl-disc.playing {
          animation: rotateDisc 15s linear infinite;
        }
      </style>
      <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; width: 100%; gap: 28px;">
        <!-- 바이닐 / 앨범 아트 -->
        <div style="position: relative;">
          <div class="vinyl-disc ${this.isPlaying ? 'playing' : ''}" style="width: 220px; height: 220px; border-radius: 50%; background: radial-gradient(circle, #1a1a24 0%, #08090f 70%, #1e1e2d 100%); border: 4px solid rgba(255, 255, 255, 0.12); box-shadow: var(--shadow-lg), 0 0 40px rgba(0, 240, 255, 0.18); display: flex; align-items: center; justify-content: center; position: relative; overflow: hidden;">
            ${coverUrl ? `<img src="${coverUrl}" style="width: 100%; height: 100%; object-fit: cover;" />` : `
              <div style="width: 80px; height: 80px; border-radius: 50%; background: var(--gradient-accent); display: flex; align-items: center; justify-content: center; box-shadow: inset 0 0 10px rgba(0,0,0,0.5);">
                <span style="font-size: 1.8rem;">🎵</span>
              </div>
            `}
          </div>
        </div>

        <!-- 트랙 메타데이터 헤더 -->
        <div style="text-align: center; max-width: 600px;">
          <h2 style="font-size: 1.6rem; font-weight: 700; margin-bottom: 6px; letter-spacing: -0.02em;">${title}</h2>
          <div style="font-size: 0.95rem; color: var(--text-secondary); margin-bottom: 12px;">${this.currentTrack.path}</div>
          <div style="display: flex; justify-content: center; gap: 8px; flex-wrap: wrap;">
            <span class="badge-neon">${format}</span>
            <span class="badge-purple">VFS Offset: 0x${this.currentTrack.offset.toString(16).toUpperCase()}</span>
            <span class="badge-neon">Size: ${(this.currentTrack.size / 1024 / 1024).toFixed(2)} MB</span>
          </div>
        </div>

        <!-- 오디오 스펙트럼 비주얼라이저 바 시뮬레이션 -->
        <div style="display: flex; align-items: flex-end; justify-content: center; gap: 4px; height: 48px; width: 300px; padding: 6px 0;">
          ${Array.from({ length: 24 }).map((_, i) => {
            const h = Math.floor(Math.sin(i) * 20 + 24);
            return `<div style="flex: 1; height: ${h}px; background: var(--gradient-accent); border-radius: 2px; opacity: 0.85;"></div>`;
          }).join('')}
        </div>
      </div>
    `;
  }
}
