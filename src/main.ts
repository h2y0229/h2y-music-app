/**
 * @file main.ts
 * @description h2y-music-app 진입점 및 컴포넌트 통합 컨트롤러
 */

import { AppShell } from './components/AppShell';
import { DropZone } from './components/DropZone';
import { MainPlayer } from './components/MainPlayer';
import { PlayerBar } from './components/PlayerBar';
import { TrackList } from './components/TrackList';
import { ArchiveAnalyzer } from './engine/archive/ArchiveAnalyzer';
import { WorkerBridge } from './engine/archive/WorkerBridge';
import './style.css';
import { ArchiveAnalysisResult, VFSEntry } from './types/vfs';

class App {
  private dropZone!: DropZone;
  private trackList!: TrackList;
  private mainPlayer!: MainPlayer;
  private playerBar!: PlayerBar;
  public readonly workerBridge: WorkerBridge;

  public currentFile: File | null = null;
  private currentAnalysis: ArchiveAnalysisResult | null = null;
  private currentTrack: VFSEntry | null = null;
  private isPlaying = false;

  constructor() {
    this.workerBridge = new WorkerBridge();
    this.init();
  }

  private init(): void {
    // 1. 전체 셸 레이아웃 초기화
    new AppShell('app');

    // 2. 드롭존 컴포넌트 초기화
    this.dropZone = new DropZone('dropzone-container', {
      onFileSelected: (file: File) => this.handleFile(file)
    });

    // 3. 트랙 리스트 컴포넌트 초기화
    this.trackList = new TrackList('tracklist-container', {
      onTrackSelect: (track: VFSEntry) => this.handleTrackSelect(track)
    });

    // 4. 중앙 메인 플레이어 초기화
    this.mainPlayer = new MainPlayer('main-player-container');

    // 5. 하단 플레이어 바 초기화
    this.playerBar = new PlayerBar('player-bar-container', {
      onPlayToggle: () => this.togglePlay(),
      onPrev: () => this.playPrevTrack(),
      onNext: () => this.playNextTrack(),
      onSeek: (percent: number) => this.seekTo(percent),
      onVolumeChange: (volume: number) => this.setVolume(volume)
    });

    console.log('🎵 h2y Music Player initialized with M1 Glassmorphism Shell & VFS Engine');
  }

  /**
   * 사용자가 드롭하거나 선택한 아카이브 파일을 분석하여 VFS 인덱스를 구축합니다.
   */
  private async handleFile(file: File): Promise<void> {
    this.currentFile = file;
    this.dropZone.setLoading(true, `${file.name} 분석 중...`);

    try {
      const format = await ArchiveAnalyzer.detectFormat(file);
      console.log(`[Archive] 파일 형식 감지: ${format} (크기: ${(file.size / 1024 / 1024).toFixed(2)} MB)`);

      if (format !== 'zip') {
        alert(`현재 ZIP 포맷의 고속 VFS Range Read를 지원합니다. (선택한 포맷: ${format.toUpperCase()})`);
        this.dropZone.setLoading(false);
        return;
      }

      const result = await ArchiveAnalyzer.analyzeZip(file);
      this.currentAnalysis = result;

      console.log(`[VFS] 분석 완료 (${result.analysisTimeMs}ms): 전체 엔트리 ${result.entryCount}개, 오디오 트랙 ${result.audioTracks.length}개`);

      // UI 갱신
      const badge = document.getElementById('track-count-badge');
      if (badge) badge.textContent = String(result.audioTracks.length);

      this.trackList.setTracks(result.audioTracks);
      this.dropZone.setLoading(false);

      // 첫 번째 트랙 자동 선택
      if (result.audioTracks.length > 0) {
        this.handleTrackSelect(result.audioTracks[0]);
      }
    } catch (err: unknown) {
      console.error('아카이브 분석 실패:', err);
      const msg = err instanceof Error ? err.message : '알 수 없는 오류';
      alert(`아카이브 분석에 실패했습니다: ${msg}`);
      this.dropZone.setLoading(false);
    }
  }

  /**
   * 오디오 트랙 선택 시 처리
   */
  private handleTrackSelect(track: VFSEntry): void {
    this.currentTrack = track;
    this.mainPlayer.setTrack(track);
    this.playerBar.setTrackInfo(track);
    this.trackList.setActiveTrack(track.id);
    console.log(`[Track Selected] ${track.name} (Offset: ${track.offset}, Size: ${track.size})`);
  }

  private togglePlay(): void {
    if (!this.currentTrack) return;
    this.isPlaying = !this.isPlaying;
    this.mainPlayer.setPlaying(this.isPlaying);
    this.playerBar.setPlayState(this.isPlaying);
  }

  private playPrevTrack(): void {
    if (!this.currentAnalysis || !this.currentTrack) return;
    const tracks = this.currentAnalysis.audioTracks;
    const currentIndex = tracks.findIndex(t => t.id === this.currentTrack?.id);
    if (currentIndex > 0) {
      this.handleTrackSelect(tracks[currentIndex - 1]);
    }
  }

  private playNextTrack(): void {
    if (!this.currentAnalysis || !this.currentTrack) return;
    const tracks = this.currentAnalysis.audioTracks;
    const currentIndex = tracks.findIndex(t => t.id === this.currentTrack?.id);
    if (currentIndex >= 0 && currentIndex < tracks.length - 1) {
      this.handleTrackSelect(tracks[currentIndex + 1]);
    }
  }

  private seekTo(percent: number): void {
    console.log(`[Seek] ${Math.round(percent * 100)}%`);
  }

  private setVolume(volume: number): void {
    console.log(`[Volume] ${Math.round(volume * 100)}%`);
  }
}

// 애플리케이션 실행
window.addEventListener('DOMContentLoaded', () => {
  new App();
});
