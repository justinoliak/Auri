# Auri – Product Requirements Document (PRD)

## 1. Document Overview

### 1.1 Purpose
Defines the vision, scope, features, and technical requirements for **Auri**, a minimal mental wellness iOS app. This PRD helps ensure alignment among product, design, engineering, and QA.

### 1.2 Intended Audience
- **Product Manager / Founder**  
- **iOS Engineers**  
- **Designers**  
- **QA / Testers**

---

## 2. Background & Context

### 2.1 Project Overview
**Auri** helps busy **18–29-year-olds** address everyday mental wellness challenges with brief journaling and lightweight techniques from **CBT** and the **Transtheoretical Model**. It emphasizes a quick, stigma-free experience, focusing on clarity and accountability.

### 2.2 Key Differentiators
1. **Minimal & Stigma-Free**: Low-pressure approach, focusing on quick, meaningful insights.  
2. **AI-Powered Personalization**: Uses voice transcription and NLP to provide relevant suggestions.  
3. **Progress Tracking**: Visual monthly data (bubble map) without the heaviness of traditional therapy apps.

### 2.3 Business & User Goals
- **Business Goals**  
  - Attract 18–29-year-olds seeking an approachable self-improvement tool.  
  - Potentially introduce subscription or freemium models.  
- **User Goals**  
  - Quick capture of thoughts or feelings in text/voice.  
  - Receive personalized, immediate insights.  
  - See trends for self-reflection and ongoing motivation.

---

## 3. Scope

### 3.1 In-Scope
- **Splash Screen & Login** (using Supabase Auth)  
- **Home Screen (Multimodal Input)**: Text or voice input, AI analysis  
- **AI Content Page**: Personalized text and AI-generated thumbnail  
- **Monthly Analysis Page**: Bubble map of emotional trends  
- **SwiftUI**: Core UI framework  
- **Supabase**: Authentication, data, storage for user info, entries, and media

### 3.2 Out-of-Scope
- Social sharing or community features  
- Complex AI beyond basic journaling analysis and content generation  
- Wearable integrations or advanced notifications

---

## 4. User Personas & Use Cases

### 4.1 Primary Persona: “Taylor” (24, Grad Student)
- **Goals**: Quick mental check-ins, immediate insights, track progress monthly.  
- **Pain Points**: Overly complex wellness apps, time constraints, stigma around therapy.

### 4.2 Use Cases
1. **Rapid Journaling**  
   - Text/voice entry → AI analysis → Quick reflection  
2. **Daily Content**  
   - Generate short, actionable tips or exercises  
3. **Monthly Self-Reflection**  
   - Bubble map of emotions/trends for deeper insight

---

## 5. Product Features & Requirements

### 5.1 Splash Screen & Login
- **Story**: “As a new user, I want quick onboarding so I can start immediately.”  
- **Requirements**: SwiftUI login form, Supabase for sign-up/sign-in, minimal branding.

### 5.2 Home Screen (Multimodal Input)
- **Story**: “As a busy user, I want to journal by typing or speaking.”  
- **Requirements**:  
  - Text input field  
  - Record button (audio → transcription)  
  - AI-driven immediate analysis summary

### 5.3 AI Content Page
- **Story**: “As a user, I want relevant, brief content to help with immediate challenges.”  
- **Requirements**:  
  - Uses an NLP/AI API to generate text  
  - AI-generated thumbnail image  
  - Content loads within ~3 seconds

### 5.4 Personalized Analysis Page
- **Story**: “As a user, I want to see a monthly overview of my moods and insights.”  
- **Requirements**:  
  - Bubble map (size = frequency or intensity of emotion)  
  - Tap to view details/trends  
  - Data pulled from user’s monthly entries in Supabase

---

## 6. Technical Architecture

### 6.1 Overview
- **iOS**: SwiftUI (iOS 14+)  
- **Backend**: Supabase (auth, database, storage)  
- **Voice to Text**: Apple Speech framework or external API  
- **AI / NLP**: Integration with OpenAI or similar service

### 6.2 Data Model (Simplified)
- **Users**  
  - `id`, `email`, `created_at`, etc.  
- **Entries**  
  - `id`, `user_id`, `text_content`, `audio_url` (optional), `analysis` (JSON)  
- **GeneratedContent**  
  - `id`, `user_id`, `summary`, `thumbnail_url`, `created_at`

### 6.3 Architecture Diagram (Conceptual)


---

## 7. User Experience (UX) & Design

### 7.1 Navigation Flow
1. **Splash/Login**  
2. **Home Screen** (text/voice input)  
3. **AI Content** (quick tips, thumbnail)  
4. **Monthly Analysis** (bubble map)

### 7.2 Design Principles
- **Minimal & Calm**: Clean layout, gentle colors/typography.  
- **Accessible**: Large buttons, support VoiceOver if possible.  
- **Consistent**: Unified design system throughout.

### 7.3 Wireframes
- **Splash/Login**: Single logo, short form  
- **Home**: Simple text field + record button  
- **AI Content**: Card-style info with a generated thumbnail  
- **Analysis**: Bubble map with dynamic sizing for emotions

---

## 8. Analytics & Metrics

### 8.1 Key KPIs
- **Daily Active Users (DAU)**  
- **Retention** (week-over-week)  
- **Entries Created** per user/day

### 8.2 Tracking Events
- **Login**  
- **Voice Entry Start/Stop**  
- **AI Content Viewed**  
- **Analysis Page Viewed**

---

## 9. Release Plan

### 9.1 Milestones
1. **MVP** (2–3 weeks): Splash/Login + Home screen journaling  
2. **AI Content + Analysis** (4–6 weeks): Integrate personalized content and monthly bubble map  
3. **Polish & Beta** (6–8 weeks): UX refinement, TestFlight release  
4. **Public Launch**: Final App Store submission

### 9.2 Dependencies
- Supabase setup (Auth, DB, Storage)  
- AI provider API and keys  
- Speech-to-text framework or service

### 9.3 Risks
- **Long AI response times** → Use placeholders + async calls  
- **App Store guidelines** → Adhere to mental health disclaimers

---

## 10. Testing & QA

### 10.1 Manual & Automated Testing
- **Manual**: Test on various iOS devices and versions  
- **Automated**:  
  - Unit tests (XCTest)  
  - SwiftUI snapshot tests if possible

### 10.2 Beta Testing
- **TestFlight**: Internal + external testers  
- **Feedback**: GitHub/Jira for bug tracking

### 10.3 Acceptance Criteria
- **Definition of Done**: Key flows tested, no critical issues, meets Apple guidelines.

---

## 11. Maintenance & Future Considerations

### 11.1 Post-Launch Plan
- **Bug Fixes**: Bi-weekly patch updates  
- **User Feedback**: In-app surveys or emails  
- **Future Features**: Reminders, social elements, deeper AI insights

### 11.2 Scalability
- **Supabase**: Scalable as user base grows  
- **AI**: Monitor API usage and costs  
- **Localization**: Possible expansion to other languages

---

## 12. Approval & Sign-Off

- **Product/Founder**:  
- **Lead iOS Engineer**:  
- **Designer**:  
- **QA Lead**:  

**Date**: _(TBD)_



