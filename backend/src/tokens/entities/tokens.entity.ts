import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class TokensEntity {
  /**
   * this decorator will help to auto generate id for the table.
   */
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 30 })
  user_id: number;

  @Column({ type: 'varchar' })
  access_token: string;
}
