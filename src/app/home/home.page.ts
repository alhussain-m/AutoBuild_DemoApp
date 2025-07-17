import { Component } from '@angular/core';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {
  envName: string;
  constructor() {
    this.envName = environment.envName;
    console.log("Environment:", this.envName);
  }
}
