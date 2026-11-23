// written by bastiaan konings schuiling 2008 - 2015
// this work is public domain. the code is undocumented, scruffy, untested, and should generally not be used for anything important.
// i do not offer support, so don't ask. to be used for inspiration :)

#include "scoreboard.hpp"

#include "utils/gui2/windowmanager.hpp"

#include <SDL2/SDL.h>
#include <algorithm>

#include "../../onthepitch/match.hpp"
#include "../../main.hpp"
#include <boost/filesystem.hpp>

using namespace blunted;

Gui2ScoreBoard::Gui2ScoreBoard(Gui2WindowManager *windowManager, Match *match)
    : Gui2View(windowManager, "scoreboard", 2, 2, 96, 5.5f), match(match) {
  x_percent = 2;
  y_percent = 2;
  width_percent = 96;
  height_percent = 5.5f;
  goalCount[0] = goalCount[1] = 0;

  // Minimal television graphic: dark navy bar, slim mint edge, white score cell.
  Gui2Image *bar = new Gui2Image(windowManager, "tv_bar", 0, 0, 61, 5.5f);
  int x, y, w, h;
  windowManager->GetCoordinates(0, 0, 61, 5.5f, x, y, w, h);
  bar->GetImage2D()->DrawRectangle(0, 0, w, h, Vector3(7, 25, 43), 250);
  bar->GetImage2D()->DrawRectangle(0, 0, w, std::max(1, h / 13), Vector3(87, 211, 194), 255);
  bar->GetImage2D()->OnChange();
  this->AddView(bar);
  bar->Show();

  Gui2Image *scoreBox = new Gui2Image(windowManager, "tv_score_box", 26, 0.65f, 10, 4.1f);
  windowManager->GetCoordinates(0, 0, 10, 4.1f, x, y, w, h);
  scoreBox->GetImage2D()->DrawRectangle(0, 0, w, h, Vector3(227, 246, 244), 255);
  scoreBox->GetImage2D()->OnChange();
  this->AddView(scoreBox);
  scoreBox->Show();

  timeCaption = new Gui2Caption(windowManager, "tv_clock", 1.3f, 1.2f, 8.3f, 2.9f, "00:00");
  teamNameCaption[0] = new Gui2Caption(windowManager, "tv_t1", 14, 1.2f, 10.5f, 2.9f,
                           match->GetTeam(0)->GetTeamData()->GetShortName());
  teamNameCaption[1] = new Gui2Caption(windowManager, "tv_t2", 38, 1.2f, 10.5f, 2.9f,
                           match->GetTeam(1)->GetTeamData()->GetShortName());
  goalCountCaption[0] = new Gui2Caption(windowManager, "tv_g1", 27, 1.0f, 3.5f, 3.2f, "0");
  goalCountCaption[1] = new Gui2Caption(windowManager, "tv_g2", 32, 1.0f, 3.5f, 3.2f, "0");
  Gui2Caption *dash = new Gui2Caption(windowManager, "tv_dash", 30.8f, 1.0f, 1.0f, 3.1f, "-");
  Gui2Caption *live = new Gui2Caption(windowManager, "tv_live", 53, 1.55f, 7, 2.0f, "EN VIVO");

  Gui2Caption *texts[] = {timeCaption, teamNameCaption[0], teamNameCaption[1],
                          goalCountCaption[0], goalCountCaption[1], dash, live};
  for (int i = 0; i < 7; ++i) {
    texts[i]->SetColor(i >= 3 && i <= 5 ? Vector3(11, 36, 48) : Vector3(243, 250, 254));
    texts[i]->SetOutlineColor(Vector3(0, 0, 0));
    this->AddView(texts[i]);
    texts[i]->Show();
  }

  teamLogo[0] = new Gui2Image(windowManager, "tv_t1_logo", 10.0f, 1.1f, 2.9f, 3.25f);
  teamLogo[1] = new Gui2Image(windowManager, "tv_t2_logo", 49.0f, 1.1f, 2.9f, 3.25f);
  for (int i = 0; i < 2; ++i) {
    teamLogo[i]->LoadImage(match->GetTeam(i)->GetTeamData()->GetLogoUrl());
    this->AddView(teamLogo[i]);
    teamLogo[i]->Show();
  }
  SetGoalCount(0, 0);
  SetGoalCount(1, 0);
  this->Show();
}

Gui2ScoreBoard::~Gui2ScoreBoard() {
  /* will be cleaned up while deleting gui2 tree automatically
  bg->Exit();
  delete bg;
  leagueLogo->Exit();
  delete leagueLogo;
  timeCaption->Exit();
  delete timeCaption;
  teamNameCaption[0]->Exit();
  delete teamNameCaption[0];
  teamNameCaption[1]->Exit();
  delete teamNameCaption[1];
  goalCountCaption[0]->Exit();
  delete goalCountCaption[0];
  goalCountCaption[1]->Exit();
  delete goalCountCaption[1];
  teamLogo[0]->Exit();
  delete teamLogo[0];
  teamLogo[1]->Exit();
  delete teamLogo[1];
  tvLogo->Exit();
  delete tvLogo;
  */
}

void Gui2ScoreBoard::GetImages(std::vector < boost::intrusive_ptr<Image2D> > &target) {
  Gui2View::GetImages(target);
}

void Gui2ScoreBoard::Redraw() {
}

void Gui2ScoreBoard::SetTimeStr(const std::string &timeStr) {
  this->timeStr = timeStr;
  timeCaption->SetCaption(timeStr);
}

void Gui2ScoreBoard::SetGoalCount(int teamID, int goalCount) {
  this->goalCount[teamID] = goalCount;
  std::string goalStr = int_to_str(goalCount);
  goalCountCaption[teamID]->SetCaption(goalStr);
}
