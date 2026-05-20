export type UserRole = "admin" | "leadership" | "hr" | "manager" | "member";

export interface AppUser {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  department_id: number;
  designation: string | null;
  standard_hours: number;
  active: boolean;
}
